-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "attendance_status" AS ENUM ('GOING', 'NOT_GOING');

-- CreateEnum
CREATE TYPE "group_role" AS ENUM ('OWNER', 'MEMBER');

-- CreateEnum
CREATE TYPE "notification_type" AS ENUM ('OUTING', 'GROUP', 'CHAT', 'VOTE', 'INVITATION', 'SYSTEM');

-- CreateEnum
CREATE TYPE "outing_occasion" AS ENUM ('NONE', 'BIRTHDAY', 'WEDDING');

-- CreateEnum
CREATE TYPE "outing_status" AS ENUM ('UPCOMING', 'VOTING', 'PAST');

-- CreateEnum
CREATE TYPE "outing_vibe" AS ENUM ('FOOD', 'ACTIVITY', 'OUTDOOR', 'MOVIE');

-- CreateEnum
CREATE TYPE "price_level" AS ENUM ('FREE', 'BUDGET', 'MODERATE', 'EXPENSIVE', 'LUXURY');

-- CreateEnum
CREATE TYPE "weekday" AS ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');

-- CreateTable
CREATE TABLE "group_members" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role" "group_role" NOT NULL DEFAULT 'MEMBER',
    "joined_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_read_at" TIMESTAMPTZ(6),

    CONSTRAINT "group_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "groups" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(120) NOT NULL,
    "image_url" TEXT NOT NULL,
    "bio" VARCHAR(160) NOT NULL DEFAULT '',
    "owner_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "type" "notification_type" NOT NULL DEFAULT 'SYSTEM',
    "title" VARCHAR(200),
    "body" TEXT NOT NULL,
    "image_url" TEXT,
    "outing_id" UUID,
    "group_id" UUID,
    "action" BOOLEAN NOT NULL DEFAULT false,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "read_at" TIMESTAMPTZ(6),
    "data" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_attendance" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "status" "attendance_status" NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_attendance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_guests" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_guests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_vote_options" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "place_id" UUID,
    "name" VARCHAR(200) NOT NULL,
    "area" VARCHAR(200) NOT NULL DEFAULT '',
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "image_url" TEXT NOT NULL DEFAULT '',
    "vibe" "outing_vibe" NOT NULL DEFAULT 'FOOD',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_vote_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "group_id" UUID,
    "created_by_id" UUID NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "image_url" TEXT NOT NULL DEFAULT '',
    "status" "outing_status" NOT NULL DEFAULT 'UPCOMING',
    "occasion" "outing_occasion" NOT NULL DEFAULT 'NONE',
    "vibe" "outing_vibe",
    "scheduled_at" TIMESTAMPTZ(6),
    "vote_deadline_hours" INTEGER,
    "vote_ends_at" TIMESTAMPTZ(6),
    "location_name" VARCHAR(200),
    "location_area" VARCHAR(200),
    "location_lat" DOUBLE PRECISION,
    "location_lng" DOUBLE PRECISION,
    "location_place_id" UUID,
    "suggested_by_name" VARCHAR(80),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "place_images" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "place_id" UUID NOT NULL,
    "image_url" TEXT NOT NULL,
    "caption" TEXT,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "place_images_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "place_prices" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "place_id" UUID NOT NULL,
    "label_key" VARCHAR(64) NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "currency" CHAR(3) NOT NULL DEFAULT 'EGP',
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "place_prices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "places" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(200) NOT NULL,
    "area" VARCHAR(200) NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "vibe" "outing_vibe" NOT NULL,
    "cover_image_url" TEXT NOT NULL,
    "price_level" "price_level" NOT NULL DEFAULT 'MODERATE',
    "price_min" DECIMAL(12,2),
    "price_max" DECIMAL(12,2),
    "currency" CHAR(3) NOT NULL DEFAULT 'EGP',
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "location" geography,
    "featured" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "places_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saved_outings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "outing_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "saved_outings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "firebase_uid" VARCHAR(128) NOT NULL,
    "name" VARCHAR(80) NOT NULL,
    "email" VARCHAR(255),
    "phone" VARCHAR(32),
    "image_url" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_chat_messages" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "sender_id" UUID NOT NULL,
    "text" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_chat_messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_chat_reads" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "last_read_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_chat_reads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_place_votes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "vote_option_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_place_votes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outing_reads" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "outing_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "seen_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "outing_reads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "place_opening_hours" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "place_id" UUID NOT NULL,
    "day" "weekday" NOT NULL,
    "is_closed" BOOLEAN NOT NULL DEFAULT false,
    "opens_at" TIME(6),
    "closes_at" TIME(6),
    "interval_index" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "place_opening_hours_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_fcm_tokens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "token" TEXT NOT NULL,
    "platform" VARCHAR(32),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_fcm_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "idx_group_members_group_role" ON "group_members"("group_id", "role");

-- CreateIndex
CREATE INDEX "idx_group_members_user_id" ON "group_members"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_group_members_group_user" ON "group_members"("group_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_groups_owner_id" ON "groups"("owner_id");

-- CreateIndex
CREATE INDEX "idx_notifications_user_created" ON "notifications"("user_id", "created_at" DESC);

-- CreateIndex
CREATE INDEX "idx_outing_attendance_outing_status" ON "outing_attendance"("outing_id", "status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_outing_attendance_outing_user" ON "outing_attendance"("outing_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_outing_guests_user_id" ON "outing_guests"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_outing_guests_outing_user" ON "outing_guests"("outing_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_outing_vote_options_outing_id" ON "outing_vote_options"("outing_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_outing_vote_options_order" ON "outing_vote_options"("outing_id", "sort_order");

-- CreateIndex
CREATE INDEX "idx_outings_created_by_id" ON "outings"("created_by_id");

-- CreateIndex
CREATE INDEX "idx_outings_group_id" ON "outings"("group_id");

-- CreateIndex
CREATE INDEX "idx_outings_group_status" ON "outings"("group_id", "status");

-- CreateIndex
CREATE INDEX "idx_outings_scheduled_at" ON "outings"("scheduled_at");

-- CreateIndex
CREATE INDEX "idx_outings_status" ON "outings"("status");

-- CreateIndex
CREATE INDEX "idx_place_images_place_id" ON "place_images"("place_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_place_images_order" ON "place_images"("place_id", "sort_order");

-- CreateIndex
CREATE INDEX "idx_place_prices_place_id" ON "place_prices"("place_id");

-- CreateIndex
CREATE INDEX "idx_places_featured" ON "places"("featured");

-- CreateIndex
CREATE INDEX "idx_places_lat_lng" ON "places"("latitude", "longitude");

-- CreateIndex
CREATE INDEX "idx_places_location_gist" ON "places" USING GIST ("location");

-- CreateIndex
CREATE INDEX "idx_places_vibe" ON "places"("vibe");

-- CreateIndex
CREATE INDEX "idx_saved_outings_user_id" ON "saved_outings"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_saved_outings_user_outing" ON "saved_outings"("user_id", "outing_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_users_firebase_uid" ON "users"("firebase_uid");

-- CreateIndex
CREATE UNIQUE INDEX "uq_users_email" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "uq_users_phone" ON "users"("phone");

-- CreateIndex
CREATE INDEX "idx_users_firebase_uid" ON "users"("firebase_uid");

-- CreateIndex
CREATE INDEX "idx_users_phone" ON "users"("phone");

-- CreateIndex
CREATE INDEX "idx_outing_chat_messages_outing_created" ON "outing_chat_messages"("outing_id", "created_at");

-- CreateIndex
CREATE INDEX "idx_outing_chat_reads_user_id" ON "outing_chat_reads"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_outing_chat_reads_outing_user" ON "outing_chat_reads"("outing_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_outing_place_votes_option_id" ON "outing_place_votes"("vote_option_id");

-- CreateIndex
CREATE INDEX "idx_outing_place_votes_outing_id" ON "outing_place_votes"("outing_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_outing_place_votes_outing_user" ON "outing_place_votes"("outing_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_outing_reads_user_id" ON "outing_reads"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_outing_reads_outing_user" ON "outing_reads"("outing_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_place_opening_hours_place_id" ON "place_opening_hours"("place_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_place_hours_day_interval" ON "place_opening_hours"("place_id", "day", "interval_index");

-- CreateIndex
CREATE UNIQUE INDEX "uq_user_fcm_tokens_token" ON "user_fcm_tokens"("token");

-- CreateIndex
CREATE INDEX "idx_user_fcm_tokens_user_id" ON "user_fcm_tokens"("user_id");

-- AddForeignKey
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_members" ADD CONSTRAINT "group_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "groups" ADD CONSTRAINT "groups_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_attendance" ADD CONSTRAINT "outing_attendance_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_attendance" ADD CONSTRAINT "outing_attendance_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_guests" ADD CONSTRAINT "outing_guests_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_guests" ADD CONSTRAINT "outing_guests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_vote_options" ADD CONSTRAINT "outing_vote_options_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_vote_options" ADD CONSTRAINT "outing_vote_options_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outings" ADD CONSTRAINT "outings_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outings" ADD CONSTRAINT "outings_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outings" ADD CONSTRAINT "outings_location_place_id_fkey" FOREIGN KEY ("location_place_id") REFERENCES "places"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "place_images" ADD CONSTRAINT "place_images_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "place_prices" ADD CONSTRAINT "place_prices_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_outings" ADD CONSTRAINT "saved_outings_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_outings" ADD CONSTRAINT "saved_outings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_chat_messages" ADD CONSTRAINT "outing_chat_messages_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_chat_messages" ADD CONSTRAINT "outing_chat_messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_chat_reads" ADD CONSTRAINT "outing_chat_reads_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_chat_reads" ADD CONSTRAINT "outing_chat_reads_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_place_votes" ADD CONSTRAINT "outing_place_votes_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_place_votes" ADD CONSTRAINT "outing_place_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_place_votes" ADD CONSTRAINT "outing_place_votes_vote_option_id_fkey" FOREIGN KEY ("vote_option_id") REFERENCES "outing_vote_options"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_reads" ADD CONSTRAINT "outing_reads_outing_id_fkey" FOREIGN KEY ("outing_id") REFERENCES "outings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "outing_reads" ADD CONSTRAINT "outing_reads_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "place_opening_hours" ADD CONSTRAINT "place_opening_hours_place_id_fkey" FOREIGN KEY ("place_id") REFERENCES "places"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_fcm_tokens" ADD CONSTRAINT "user_fcm_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

