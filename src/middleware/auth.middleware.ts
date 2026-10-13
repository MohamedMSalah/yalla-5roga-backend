import type { NextFunction, Request, Response } from "express";
import { getFirebaseAuth } from "../config/firebase.js";
import { UnauthorizedError } from "../utils/errors.js";

function extractBearerToken(req: Request): string | null {
  const header = req.headers.authorization;
  if (!header) return null;

  const [scheme, token] = header.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token) return null;

  return token;
}

function logTokenDiagnostics(header: string | undefined, token: string) {
  const segments = token.split(".");
  const hasSurroundingQuotes =
    (token.startsWith('"') && token.endsWith('"') && token.length >= 2) ||
    (token.startsWith("'") && token.endsWith("'") && token.length >= 2);

  console.error("[Firebase Auth] Token diagnostics", {
    authorizationHeaderPresent: Boolean(header),
    scheme: header?.split(" ")[0] ?? null,
    tokenLength: token.length,
    segmentCount: segments.length,
    hasEmptySegment: segments.some((segment) => segment.length === 0),
    hasLeadingOrTrailingWhitespace: token !== token.trim(),
    hasSurroundingQuotes,
    hasUnexpectedBearerPrefix: /^bearer\s+/i.test(token),
  });
}

async function verifyToken(token: string, header: string | undefined) {
  logTokenDiagnostics(header, token);
  const decoded = await getFirebaseAuth().verifyIdToken(token);

  return {
    uid: decoded.uid,
    email: decoded.email,
    name: decoded.name,
    // Firebase sets phone_number only after the number is verified.
    phone: decoded.phone_number,
    signInProvider: decoded.firebase?.sign_in_provider,
  };
}

function errorDetails(error: unknown) {
  if (error instanceof Error) {
    const coded = error as Error & { code?: unknown };
    return {
      code: coded.code,
      name: error.name,
      message: error.message,
      stack: error.stack,
    };
  }

  return {
    code: undefined,
    name: undefined,
    message: typeof error === "string" ? error : "Unknown error",
    stack: undefined,
  };
}

function isFirebaseAuthError(error: unknown): boolean {
  if (typeof error !== "object" || error === null) return false;

  const details = error as { code?: unknown; codePrefix?: unknown; name?: unknown };
  return (
    details.name === "FirebaseAuthError" ||
    details.codePrefix === "auth" ||
    (typeof details.code === "string" && details.code.startsWith("auth/"))
  );
}

export async function authMiddleware(
  req: Request,
  _res: Response,
  next: NextFunction,
) {
  try {
    const token = extractBearerToken(req);
    if (!token) {
      throw new UnauthorizedError("Missing Bearer token");
    }

    req.user = await verifyToken(token, req.headers.authorization);
    next();
  } catch (error) {
    if (error instanceof UnauthorizedError) {
      return next(error);
    }

    const details = errorDetails(error);
    if (isFirebaseAuthError(error)) {
      console.error("[Firebase Auth] Token verification failed", details);
    } else {
      console.error("[Auth Middleware] Unexpected error", details);
    }
    return next(new UnauthorizedError("Invalid or expired Firebase token"));
  }
}

export async function optionalAuthMiddleware(
  req: Request,
  _res: Response,
  next: NextFunction,
) {
  try {
    const token = extractBearerToken(req);
    if (token) {
      req.user = await verifyToken(token, req.headers.authorization);
    }
    next();
  } catch {
    next();
  }
}
