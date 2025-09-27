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

ActiveRecord::Schema[8.0].define(version: 2025_09_27_060008) do
  create_table "creator_position_invites", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "email"
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invited_by_id", null: false
    t.index ["invited_by_id"], name: "index_creator_position_invites_on_invited_by_id"
    t.index ["project_id"], name: "index_creator_position_invites_on_project_id"
  end

  create_table "creator_positions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 1, null: false
    t.index ["project_id"], name: "index_creator_positions_on_project_id"
    t.index ["role"], name: "index_creator_positions_on_role"
    t.index ["user_id"], name: "index_creator_positions_on_user_id"
  end

  create_table "prechecks", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "status"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_prechecks_on_project_id"
  end

  create_table "profile_data", force: :cascade do |t|
    t.integer "user_id", null: false
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
    t.integer "attending_event"
    t.index ["user_id"], name: "index_profile_data_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "itchio_url"
    t.string "repo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "creator_position_invites", "projects"
  add_foreign_key "creator_position_invites", "users", column: "invited_by_id"
  add_foreign_key "creator_positions", "projects"
  add_foreign_key "creator_positions", "users"
  add_foreign_key "prechecks", "projects"
  add_foreign_key "profile_data", "users"
  add_foreign_key "tokens", "users"
end
