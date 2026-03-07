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

ActiveRecord::Schema[8.1].define(version: 2026_03_07_022218) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

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
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cellar_id", "user_id"], name: "index_cellar_memberships_on_cellar_id_and_user_id", unique: true
    t.index ["cellar_id"], name: "index_cellar_memberships_on_cellar_id"
    t.index ["user_id"], name: "index_cellar_memberships_on_user_id"
  end

  create_table "cellars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_cellars_on_owner_id"
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

  create_table "wines", force: :cascade do |t|
    t.integer "bottle_size_ml"
    t.string "canonical_key", null: false
    t.bigint "cellar_id", null: false
    t.datetime "created_at", null: false
    t.string "normalized_wine_name", null: false
    t.string "normalized_winery", null: false
    t.integer "purchase_price_cents", default: 0, null: false
    t.string "region"
    t.datetime "updated_at", null: false
    t.string "varietal"
    t.integer "vintage"
    t.string "wine_name", null: false
    t.string "wine_type"
    t.string "winery", null: false
    t.index ["cellar_id", "canonical_key"], name: "index_wines_on_cellar_id_and_canonical_key", unique: true
    t.index ["cellar_id"], name: "index_wines_on_cellar_id"
    t.index ["normalized_wine_name"], name: "index_wines_on_normalized_wine_name"
    t.index ["normalized_winery"], name: "index_wines_on_normalized_winery"
    t.index ["wine_name"], name: "index_wines_on_wine_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["winery"], name: "index_wines_on_winery", opclass: :gin_trgm_ops, using: :gin
  end

  add_foreign_key "cellar_invitations", "cellars"
  add_foreign_key "cellar_invitations", "users", column: "invited_by_id"
  add_foreign_key "cellar_memberships", "cellars"
  add_foreign_key "cellar_memberships", "users"
  add_foreign_key "cellars", "users", column: "owner_id"
  add_foreign_key "tags", "cellars"
  add_foreign_key "wine_tags", "tags"
  add_foreign_key "wine_tags", "wines"
  add_foreign_key "wines", "cellars"
end
