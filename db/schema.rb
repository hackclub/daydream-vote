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

ActiveRecord::Schema[8.0].define(version: 2025_09_27_200024) do
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

  create_table "creator_position_invites", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "email"
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "invited_by_id", null: false
    t.index ["invited_by_id"], name: "index_creator_position_invites_on_invited_by_id"
    t.index ["project_id"], name: "index_creator_position_invites_on_project_id"
  end

  create_table "creator_positions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 1, null: false
    t.index ["project_id"], name: "index_creator_positions_on_project_id"
    t.index ["role"], name: "index_creator_positions_on_role"
    t.index ["user_id"], name: "index_creator_positions_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_email"
    t.boolean "voting_enabled", default: false, null: false
    t.string "humanized_name"
    t.string "confirmed_event_airtable_id"
    t.index ["name"], name: "index_events_on_name", unique: true
  end

  create_table "organizer_positions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_organizer_positions_on_event_id"
    t.index ["user_id", "event_id"], name: "index_organizer_positions_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_organizer_positions_on_user_id"
  end

  create_table "prechecks", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "status"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_prechecks_on_project_id"
  end

  create_table "profile_data", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.date "dob"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zip_code"
    t.string "address_country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profile_data_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "itchio_url"
    t.string "repo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.datetime "submitted_at"
    t.bigint "attending_event_id", null: false
    t.boolean "hidden", default: false, null: false
    t.string "airtable_record_id"
    t.datetime "last_synced_to_airtable_at"
    t.index ["airtable_record_id"], name: "index_projects_on_airtable_record_id"
    t.index ["attending_event_id"], name: "index_projects_on_attending_event_id"
  end

  create_table "tokens", id: :string, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.boolean "used", default: false, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_tokens_on_id", unique: true
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_votes_on_project_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "creator_position_invites", "projects"
  add_foreign_key "creator_position_invites", "users", column: "invited_by_id"
  add_foreign_key "creator_positions", "projects"
  add_foreign_key "creator_positions", "users"
  add_foreign_key "organizer_positions", "events"
  add_foreign_key "organizer_positions", "users"
  add_foreign_key "prechecks", "projects"
  add_foreign_key "profile_data", "users"
  add_foreign_key "projects", "events", column: "attending_event_id"
  add_foreign_key "tokens", "users"
  add_foreign_key "votes", "projects"
  add_foreign_key "votes", "users"
end
