# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_27_194541) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "approvals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "venue_id", null: false
    t.bigint "event_id"
    t.integer "approval_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "qr_code_data"
    t.datetime "expires_at"
    t.boolean "qr_used", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_approvals_on_event_id"
    t.index ["qr_code_data"], name: "index_approvals_on_qr_code_data", unique: true
    t.index ["status"], name: "index_approvals_on_status"
    t.index ["user_id", "venue_id", "event_id"], name: "index_approvals_uniqueness", unique: true
    t.index ["user_id"], name: "index_approvals_on_user_id"
    t.index ["venue_id"], name: "index_approvals_on_venue_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "date_time", null: false
    t.boolean "allow_global_approval", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_time"], name: "index_events_on_date_time"
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "otp_codes", force: :cascade do |t|
    t.string "phone_number", null: false
    t.string "code", null: false
    t.datetime "expires_at", null: false
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_otp_codes_on_expires_at"
    t.index ["phone_number"], name: "index_otp_codes_on_phone_number"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "refresh_token", null: false
    t.datetime "expires_at", null: false
    t.string "device_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["refresh_token"], name: "index_sessions_on_refresh_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number", null: false
    t.boolean "phone_verified", default: false, null: false
    t.jsonb "social_links", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
  end

  create_table "venue_admins", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_venue_admins_on_email", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "address"
    t.bigint "venue_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["venue_admin_id"], name: "index_venues_on_venue_admin_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "approvals", "events"
  add_foreign_key "approvals", "users"
  add_foreign_key "approvals", "venues"
  add_foreign_key "events", "venues"
  add_foreign_key "sessions", "users"
  add_foreign_key "venues", "venue_admins"
end
