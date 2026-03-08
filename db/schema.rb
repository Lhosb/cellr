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

ActiveRecord::Schema[8.1].define(version: 2026_03_08_011300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "cellar_entries", force: :cascade do |t|
    t.integer "bottle_size_ml"
    t.bigint "cellar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "drunk_at"
    t.text "notes"
    t.integer "purchase_price_cents", default: 0, null: false
    t.integer "state", default: 0, null: false
    t.text "tasting_notes"
    t.datetime "updated_at", null: false
    t.integer "vintage"
    t.bigint "wine_id", null: false
    t.index ["cellar_id", "state"], name: "index_cellar_entries_on_cellar_id_and_state"
    t.index ["cellar_id"], name: "index_cellar_entries_on_cellar_id"
    t.index ["wine_id"], name: "index_cellar_entries_on_wine_id"
  end

  create_table "cellar_invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.bigint "cellar_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "invited_by_id", null: false
    t.integer "role", default: 2, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["cellar_id"], name: "index_cellar_invitations_on_cellar_id"
    t.index ["invited_by_id"], name: "index_cellar_invitations_on_invited_by_id"
    t.index ["token"], name: "index_cellar_invitations_on_token", unique: true
  end

  create_table "cellar_memberships", force: :cascade do |t|
    t.bigint "cellar_id", null: false
    t.datetime "created_at", null: false
    t.boolean "default", default: false, null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cellar_id", "user_id"], name: "index_cellar_memberships_on_cellar_id_and_user_id", unique: true
    t.index ["cellar_id"], name: "index_cellar_memberships_on_cellar_id"
    t.index ["user_id"], name: "index_cellar_memberships_on_user_id"
    t.index ["user_id"], name: "index_cellar_memberships_on_user_id_where_default", unique: true, where: "(\"default\" = true)"
  end

  create_table "cellars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_cellars_on_owner_id"
  end

  create_table "drinking_records", force: :cascade do |t|
    t.bigint "cellar_entry_id", null: false
    t.datetime "consumed_at", null: false
    t.datetime "created_at", null: false
    t.bigint "drinking_session_id", null: false
    t.integer "quantity", default: 1, null: false
    t.text "tasting_notes"
    t.datetime "updated_at", null: false
    t.index ["cellar_entry_id"], name: "index_drinking_records_on_cellar_entry_id"
    t.index ["drinking_session_id", "consumed_at"], name: "index_drinking_records_on_session_and_consumed_at"
    t.index ["drinking_session_id"], name: "index_drinking_records_on_drinking_session_id"
    t.check_constraint "quantity > 0", name: "check_drinking_records_quantity_positive"
  end

  create_table "drinking_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "ended_at"
    t.datetime "last_activity_at", null: false
    t.datetime "started_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["date", "ended_at", "last_activity_at", "id"], name: "index_drinking_sessions_on_active_feed", order: { last_activity_at: :desc, id: :desc }
    t.index ["user_id", "date"], name: "index_drinking_sessions_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_drinking_sessions_on_user_id"
    t.check_constraint "ended_at IS NULL OR ended_at >= started_at", name: "check_drinking_sessions_ended_after_start"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "feature_key", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
  end

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.jsonb "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "normalized_name", null: false
    t.datetime "updated_at", null: false
    t.index ["normalized_name"], name: "index_regions_on_normalized_name", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "cellar_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["cellar_id", "name"], name: "index_tags_on_cellar_id_and_name", unique: true
    t.index ["cellar_id"], name: "index_tags_on_cellar_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wine_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "wine_id", null: false
    t.index ["tag_id"], name: "index_wine_tags_on_tag_id"
    t.index ["wine_id", "tag_id"], name: "index_wine_tags_on_wine_id_and_tag_id", unique: true
    t.index ["wine_id"], name: "index_wine_tags_on_wine_id"
  end

  create_table "wineries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "normalized_name", null: false
    t.datetime "updated_at", null: false
    t.index ["normalized_name"], name: "index_wineries_on_normalized_name", unique: true
  end

  create_table "wines", force: :cascade do |t|
    t.integer "bottle_size_ml"
    t.string "canonical_key", null: false
    t.bigint "cellar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "drunk_at"
    t.string "normalized_wine_name", null: false
    t.string "normalized_winery", null: false
    t.text "notes"
    t.integer "purchase_price_cents", default: 0, null: false
    t.string "region"
    t.bigint "region_id", null: false
    t.integer "state", default: 0, null: false
    t.text "tasting_notes"
    t.datetime "updated_at", null: false
    t.string "varietal"
    t.integer "vintage"
    t.string "wine_name", null: false
    t.string "wine_type"
    t.bigint "winery_id", null: false
    t.index ["cellar_id", "canonical_key"], name: "index_wines_on_cellar_id_and_canonical_key"
    t.index ["cellar_id"], name: "index_wines_on_cellar_id"
    t.index ["normalized_wine_name"], name: "index_wines_on_normalized_wine_name"
    t.index ["normalized_winery"], name: "index_wines_on_normalized_winery"
    t.index ["region_id"], name: "index_wines_on_region_id"
    t.index ["wine_name"], name: "index_wines_on_wine_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["winery_id"], name: "index_wines_on_winery_id"
  end

  add_foreign_key "cellar_entries", "cellars"
  add_foreign_key "cellar_entries", "wines"
  add_foreign_key "cellar_invitations", "cellars"
  add_foreign_key "cellar_invitations", "users", column: "invited_by_id"
  add_foreign_key "cellar_memberships", "cellars"
  add_foreign_key "cellar_memberships", "users"
  add_foreign_key "cellars", "users", column: "owner_id"
  add_foreign_key "drinking_records", "cellar_entries"
  add_foreign_key "drinking_records", "drinking_sessions"
  add_foreign_key "drinking_sessions", "users"
  add_foreign_key "tags", "cellars"
  add_foreign_key "wine_tags", "tags"
  add_foreign_key "wine_tags", "wines"
  add_foreign_key "wines", "cellars"
  add_foreign_key "wines", "regions"
  add_foreign_key "wines", "wineries"
end
