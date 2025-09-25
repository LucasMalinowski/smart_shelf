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

ActiveRecord::Schema[7.1].define(version: 2025_04_22_103854) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon_name"
  end

  create_table "category_measurement_units", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "measurement_unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_category_measurement_units_on_category_id"
    t.index ["measurement_unit_id"], name: "index_category_measurement_units_on_measurement_unit_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "invite_code", null: false
    t.string "unit_system", default: "metric", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invite_code"], name: "index_families_on_invite_code", unique: true
    t.index ["slug"], name: "index_families_on_slug", unique: true
  end

  create_table "family_invitations", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.integer "status", default: 0, null: false
    t.bigint "invited_by_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id", "email"], name: "index_family_invitations_on_family_id_and_email", unique: true
    t.index ["family_id"], name: "index_family_invitations_on_family_id"
    t.index ["invited_by_id"], name: "index_family_invitations_on_invited_by_id"
    t.index ["token"], name: "index_family_invitations_on_token", unique: true
  end

  create_table "family_notifications", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "inventory_item_id"
    t.string "kind", null: false
    t.string "title", null: false
    t.text "body"
    t.integer "status", default: 0, null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "triggered_at", null: false
    t.datetime "read_at"
    t.bigint "read_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id", "status"], name: "index_family_notifications_on_family_id_and_status"
    t.index ["family_id"], name: "index_family_notifications_on_family_id"
    t.index ["inventory_item_id"], name: "index_family_notifications_on_inventory_item_id"
    t.index ["read_by_id"], name: "index_family_notifications_on_read_by_id"
    t.index ["triggered_at"], name: "index_family_notifications_on_triggered_at"
  end

  create_table "grocery_list_items", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.integer "quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id", null: false
    t.index ["family_id"], name: "index_grocery_list_items_on_family_id"
    t.index ["item_id"], name: "index_grocery_list_items_on_item_id"
  end

  create_table "hidden_inventory_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "inventory_item_id", null: false
    t.datetime "hidden_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_item_id"], name: "index_hidden_inventory_items_on_inventory_item_id"
    t.index ["user_id", "inventory_item_id"], name: "index_hidden_items_on_user_and_inventory", unique: true
    t.index ["user_id"], name: "index_hidden_inventory_items_on_user_id"
  end

  create_table "inventory_items", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.decimal "quantity", precision: 12, scale: 3, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id", null: false
    t.bigint "measurement_unit_id"
    t.string "custom_unit_name"
    t.decimal "custom_unit_step", precision: 8, scale: 3, default: "1.0", null: false
    t.integer "unit_precision", default: 0, null: false
    t.decimal "minimum_quantity", precision: 12, scale: 3
    t.decimal "critical_quantity", precision: 12, scale: 3
    t.datetime "expires_at"
    t.datetime "last_restocked_at"
    t.datetime "low_stock_notified_at"
    t.datetime "critical_stock_notified_at"
    t.datetime "expiration_notified_at"
    t.jsonb "metadata", default: {}, null: false
    t.index ["family_id", "item_id"], name: "index_inventory_items_on_family_id_and_item_id", unique: true
    t.index ["family_id"], name: "index_inventory_items_on_family_id"
    t.index ["item_id"], name: "index_inventory_items_on_item_id"
    t.index ["measurement_unit_id"], name: "index_inventory_items_on_measurement_unit_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "default_measurement_unit_id"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["default_measurement_unit_id"], name: "index_items_on_default_measurement_unit_id"
  end

  create_table "measurement_units", force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name"
    t.string "unit_type", default: "unit", null: false
    t.decimal "step", precision: 8, scale: 3, default: "1.0", null: false
    t.boolean "fractional", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_measurement_units_on_name", unique: true
  end

  create_table "user_category_orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_user_category_orders_on_category_id"
    t.index ["user_id", "category_id"], name: "index_user_category_orders_on_user_id_and_category_id", unique: true
    t.index ["user_id", "position"], name: "index_user_category_orders_on_user_id_and_position"
    t.index ["user_id"], name: "index_user_category_orders_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id", null: false
    t.string "theme_preference"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "category_measurement_units", "categories"
  add_foreign_key "category_measurement_units", "measurement_units"
  add_foreign_key "family_invitations", "families"
  add_foreign_key "family_invitations", "users", column: "invited_by_id"
  add_foreign_key "family_notifications", "families"
  add_foreign_key "family_notifications", "inventory_items"
  add_foreign_key "family_notifications", "users", column: "read_by_id"
  add_foreign_key "grocery_list_items", "families"
  add_foreign_key "grocery_list_items", "items"
  add_foreign_key "hidden_inventory_items", "inventory_items"
  add_foreign_key "hidden_inventory_items", "users"
  add_foreign_key "inventory_items", "families"
  add_foreign_key "inventory_items", "items"
  add_foreign_key "inventory_items", "measurement_units"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "measurement_units", column: "default_measurement_unit_id"
  add_foreign_key "user_category_orders", "categories"
  add_foreign_key "user_category_orders", "users"
  add_foreign_key "users", "families"
end
