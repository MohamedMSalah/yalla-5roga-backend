-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "attendance_status" AS ENUM ('going', 'not_going', 'not_voted');

-- CreateEnum
CREATE TYPE "group_role" AS ENUM ('owner', 'admin', 'member');

-- CreateEnum
CREATE TYPE "message_delivery_status" AS ENUM ('sent', 'delivered', 'seen');

-- CreateEnum
CREATE TYPE "notification_type" AS ENUM ('outing', 'group', 'chat', 'vote', 'invitation', 'system');

-- CreateEnum
CREATE TYPE "outing_occasion" AS ENUM ('none', 'birthday', 'wedding');

-- CreateEnum
CREATE TYPE "outing_status" AS ENUM ('upcoming', 'voting', 'past');

-- CreateEnum
CREATE TYPE "outing_vibe" AS ENUM ('food', 'activity', 'outdoor', 'movie');

-- CreateEnum
CREATE TYPE "price_level" AS ENUM ('free', 'budget', 'moderate', 'expensive', 'luxury');

-- CreateEnum
CREATE TYPE "weekday" AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');

-- CreateTable
CREATE TABLE "chat_messages" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "sender_id" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "delivery_status" "message_delivery_status" NOT NULL DEFAULT 'sent',
    "sent_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_read_cursors" (
    "outing_id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,
    "last_read_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "chat_read_cursors_pkey" PRIMARY KEY ("outing_id","user_id")
);

-- CreateTable
CREATE TABLE "fcm_tokens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "platform" TEXT,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fcm_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "group_invites" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "invited_by_id" TEXT NOT NULL,
    "phone" TEXT,
    "invited_user_id" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "group_invites_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "group_members" (
    "group_id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,
    "role" "group_role" NOT NULL DEFAULT 'member',
    "joined_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "group_members_pkey" PRIMARY KEY ("group_id","user_id")
);

-- CreateTable
CREATE TABLE "group_read_cursors" (
    "group_id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,
    "last_read_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "group_read_cursors_pkey" PRIMARY KEY ("group_id","user_id")
);

-- CreateTable
CREATE TABLE "groups" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" TEXT NOT NULL,
    "image_url" TEXT NOT NULL DEFAULT '',
    "featured" BOOLEAN NOT NULL DEFAULT false,
    "decision" TEXT,
    "created_by_id" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "type" "notification_type" NOT NULL DEFAULT 'system',
    "image_url" TEXT,
    "outing_id" UUID,
    "group_id" UUID,
    "action" BOOLEAN NOT NULL DEFAULT false,
    "unread" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_attendance" (
    "outing_id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,
    "status" "attendance_status" NOT NULL DEFAULT 'not_voted',
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_attendance_pkey" PRIMARY KEY ("outing_id","user_id")
);

-- CreateTable
CREATE TABLE "outing_drafts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" TEXT NOT NULL,
    "title" TEXT NOT NULL DEFAULT '',
    "image_url" TEXT NOT NULL DEFAULT '',
    "location_name" TEXT NOT NULL DEFAULT '',
    "location_area" TEXT NOT NULL DEFAULT '',
    "location_lat" DOUBLE PRECISION,
    "location_lng" DOUBLE PRECISION,
    "date" DATE,
    "hour" INTEGER NOT NULL DEFAULT 11,
    "minute" INTEGER NOT NULL DEFAULT 30,
    "vibe" "outing_vibe" NOT NULL DEFAULT 'food',
    "group_id" UUID,
    "occasion" "outing_occasion" NOT NULL DEFAULT 'none',
    "special_event" BOOLEAN NOT NULL DEFAULT false,
    "let_vote" BOOLEAN NOT NULL DEFAULT false,
    "vote_deadline_hours" INTEGER,
    "guest_ids" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "selected_places" JSONB NOT NULL DEFAULT '[]',
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_drafts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_guests" (
    "outing_id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,

    CONSTRAINT "outing_guests_pkey" PRIMARY KEY ("outing_id","user_id")
);

-- CreateTable
CREATE TABLE "outing_vote_options" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "place_id" UUID NOT NULL,
    "label" TEXT NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "outing_vote_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_votes" (
    "outing_id" UUID NOT NULL,
    "user_id" TEXT NOT NULL,
    "option_id" UUID NOT NULL,
    "voted_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_votes_pkey" PRIMARY KEY ("outing_id","user_id")
);

-- CreateTable
CREATE TABLE "outings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "title" TEXT NOT NULL,
    "image_url" TEXT NOT NULL DEFAULT '',
    "group_id" UUID,
    "created_by_id" TEXT,
    "status" "outing_status" NOT NULL DEFAULT 'upcoming',
    "occasion" "outing_occasion" NOT NULL DEFAULT 'none',
    "scheduled_at" TIMESTAMPTZ(6),
    "location_name" TEXT,
    "location_area" TEXT,
    "location_lat" DOUBLE PRECISION,
    "location_lng" DOUBLE PRECISION,
    "location_place_id" UUID,
    "vote_deadline_hours" INTEGER,
    "vote_ends_at" TIMESTAMPTZ(6),
    "suggested_by_id" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "place_hours" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "place_id" UUID NOT NULL,
    "day" "weekday" NOT NULL,
    "opens_at" TIME(6),
    "closes_at" TIME(6),
    "is_closed" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "place_hours_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "place_images" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "place_id" UUID NOT NULL,
    "image_url" TEXT NOT NULL,
    "caption" TEXT,
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "place_images_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "place_prices" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "place_id" UUID NOT NULL,
    "label_key" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'EGP',

    CONSTRAINT "place_prices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "places" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" TEXT NOT NULL,
    "area" TEXT NOT NULL DEFAULT '',
    "vibe" "outing_vibe" NOT NULL DEFAULT 'food',
    "cover_image_url" TEXT NOT NULL DEFAULT '',
    "description" TEXT NOT NULL DEFAULT '',
    "price_level" "price_level" NOT NULL DEFAULT 'moderate',
    "price_min" DECIMAL(12,2),
    "price_max" DECIMAL(12,2),
    "currency" TEXT NOT NULL DEFAULT 'EGP',
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "featured" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "places_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saved_outings" (
    "user_id" TEXT NOT NULL,
    "outing_id" UUID NOT NULL,
    "saved_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "saved_outings_pkey" PRIMARY KEY ("user_id","outing_id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT,
    "image_url" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "password_hash" TEXT,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "chat_messages_outing_sent_idx" ON "chat_messages"("outing_id", "sent_at");

-- CreateIndex
CREATE UNIQUE INDEX "fcm_tokens_token_key" ON "fcm_tokens"("token");

-- CreateIndex
CREATE INDEX "notifications_user_created_idx" ON "notifications"("user_id", "created_at" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "outing_vote_options_outing_id_place_id_key" ON "outing_vote_options"("outing_id", "place_id");

-- CreateIndex
CREATE UNIQUE INDEX "place_hours_place_id_day_key" ON "place_hours"("place_id", "day");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "chat_messages" ADD CONSTRAINT "chat_messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "chat_read_cursors" ADD CONSTRAINT "chat_read_cursors_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "chat_read_cursors" ADD CONSTRAINT "chat_read_cursors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "fcm_tokens" ADD CONSTRAINT "fcm_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "group_invites" ADD CONSTRAINT "group_invites_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "group_invites" ADD CONSTRAINT "group_invites_invited_by_id_fkey" FOREIGN KEY ("invited_by_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "group_invites" ADD CONSTRAINT "group_invites_invited_user_id_fkey" FOREIGN KEY ("invited_user_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "group_read_cursors" ADD CONSTRAINT "group_read_cursors_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "group_read_cursors" ADD CONSTRAINT "group_read_cursors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "groups" ADD CONSTRAINT "groups_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_attendance" ADD CONSTRAINT "outing_attendance_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_attendance" ADD CONSTRAINT "outing_attendance_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_drafts" ADD CONSTRAINT "outing_drafts_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_drafts" ADD CONSTRAINT "outing_drafts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_guests" ADD CONSTRAINT "outing_guests_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_guests" ADD CONSTRAINT "outing_guests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_vote_options" ADD CONSTRAINT "outing_vote_options_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_vote_options" ADD CONSTRAINT "outing_vote_options_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_votes" ADD CONSTRAINT "outing_votes_option_id_fkey" FOREIGN KEY ("option_id") REFERENCES "outing_vote_options"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_votes" ADD CONSTRAINT "outing_votes_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outing_votes" ADD CONSTRAINT "outing_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outings" ADD CONSTRAINT "outings_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outings" ADD CONSTRAINT "outings_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outings" ADD CONSTRAINT "outings_location_place_id_fkey" FOREIGN KEY ("location_place_id") REFERENCES "places"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "outings" ADD CONSTRAINT "outings_suggested_by_id_fkey" FOREIGN KEY ("suggested_by_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "place_hours" ADD CONSTRAINT "place_hours_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "place_images" ADD CONSTRAINT "place_images_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "place_prices" ADD CONSTRAINT "place_prices_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "saved_outings" ADD CONSTRAINT "saved_outings_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "saved_outings" ADD CONSTRAINT "saved_outings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

