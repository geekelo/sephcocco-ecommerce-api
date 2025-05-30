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

ActiveRecord::Schema[7.2].define(version: 2025_05_25_234717) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pharmacy_product_categories_pharmacy_products", id: false, force: :cascade do |t|
    t.uuid "pharmacy_product_id", null: false
    t.uuid "pharmacy_product_category_id", null: false
    t.index ["pharmacy_product_id", "pharmacy_product_category_id"], name: "index_pharmacy_products_categories_on_product_and_category", unique: true
  end

  create_table "restaurant_product_categories_restaurant_products", id: false, force: :cascade do |t|
    t.uuid "restaurant_product_id", null: false
    t.uuid "restaurant_product_category_id", null: false
    t.index ["restaurant_product_id", "restaurant_product_category_id"], name: "index_restaurant_products_categories_on_product_and_category", unique: true
  end

  create_table "sephcocco_lounge_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.string "status_history", default: [], array: true
    t.decimal "amount", precision: 10, scale: 2
    t.string "payment_method"
    t.string "transaction_id"
    t.string "orders", default: [], array: true
    t.uuid "sephcocco_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "index_sephcocco_lounge_payments_on_sephcocco_user_id"
  end

  create_table "sephcocco_lounge_product_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sephcocco_lounge_product_categories_on_name", unique: true
    t.index ["slug"], name: "index_sephcocco_lounge_product_categories_on_slug", unique: true
  end

  create_table "sephcocco_lounge_product_categories_products", id: false, force: :cascade do |t|
    t.uuid "sephcocco_lounge_product_id", null: false
    t.uuid "sephcocco_lounge_product_category_id", null: false
    t.index ["sephcocco_lounge_product_id", "sephcocco_lounge_product_category_id"], name: "index_products_categories_on_product_and_category", unique: true
  end

  create_table "sephcocco_lounge_product_likes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.uuid "sephcocco_lounge_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id", "sephcocco_lounge_product_id"], name: "index_sephcocco_lounge_product_likes_on_user_and_product", unique: true
  end

  create_table "sephcocco_lounge_products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "image_url"
    t.decimal "price", precision: 16, scale: 2, default: "0.0", null: false
    t.integer "amount_in_stock", default: 0, null: false
    t.string "short_description"
    t.text "long_description"
    t.string "other_images", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sephcocco_lounge_products_on_name", unique: true
  end

  create_table "sephcocco_pharmacy_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_pharmacy_product_id", null: false
    t.uuid "sephcocco_user_id", null: false
    t.string "status", default: "pending", null: false
    t.string "stages", default: [], array: true
    t.string "current_stage", null: false
    t.string "order_number", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.decimal "total_cost", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_pharmacy_product_id"], name: "idx_on_sephcocco_pharmacy_product_id_87c79f77bf"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_pharmacy_orders_on_sephcocco_user_id"
  end

  create_table "sephcocco_pharmacy_product_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sephcocco_pharmacy_product_categories_on_name", unique: true
    t.index ["slug"], name: "index_sephcocco_pharmacy_product_categories_on_slug", unique: true
  end

  create_table "sephcocco_pharmacy_product_likes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.uuid "sephcocco_pharmacy_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id", "sephcocco_pharmacy_product_id"], name: "index_sephcocco_pharmacy_product_likes_on_user_and_product", unique: true
  end

  create_table "sephcocco_pharmacy_products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "image_url"
    t.decimal "price", precision: 16, scale: 2, default: "0.0", null: false
    t.integer "amount_in_stock", default: 0, null: false
    t.string "short_description"
    t.text "long_description"
    t.string "other_images", default: [], array: true
    t.integer "likes", default: 0, null: false
    t.boolean "visible", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_urls", default: [], array: true
    t.index ["name"], name: "index_sephcocco_pharmacy_products_on_name", unique: true
  end

  create_table "sephcocco_restaurant_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_restaurant_product_id", null: false
    t.uuid "sephcocco_user_id", null: false
    t.string "status", default: "pending", null: false
    t.string "stages", default: [], array: true
    t.string "current_stage", null: false
    t.string "order_number", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.decimal "total_cost", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_restaurant_product_id"], name: "idx_on_sephcocco_restaurant_product_id_862b37aba9"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_restaurant_orders_on_sephcocco_user_id"
  end

  create_table "sephcocco_restaurant_product_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sephcocco_restaurant_product_categories_on_name", unique: true
    t.index ["slug"], name: "index_sephcocco_restaurant_product_categories_on_slug", unique: true
  end

  create_table "sephcocco_restaurant_product_likes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.uuid "sephcocco_restaurant_product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id", "sephcocco_restaurant_product_id"], name: "index_sephcocco_restaurant_product_likes_on_user_and_product", unique: true
  end

  create_table "sephcocco_restaurant_products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "image_url"
    t.decimal "price", precision: 16, scale: 2, default: "0.0", null: false
    t.integer "amount_in_stock", default: 0, null: false
    t.string "short_description"
    t.text "long_description"
    t.string "other_images", default: [], array: true
    t.integer "likes", default: 0, null: false
    t.boolean "visible", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_urls", default: [], array: true
    t.index ["name"], name: "index_sephcocco_restaurant_products_on_name", unique: true
  end

  create_table "sephcocco_user_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sephcocco_user_roles_on_name", unique: true
  end

  create_table "sephcocco_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.text "address"
    t.string "phone_number"
    t.string "whatsapp_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sephcocco_user_role_id", null: false
    t.index ["email"], name: "index_sephcocco_users_on_email", unique: true
    t.index ["sephcocco_user_role_id"], name: "index_sephcocco_users_on_sephcocco_user_role_id"
  end

  add_foreign_key "sephcocco_lounge_payments", "sephcocco_users"
  add_foreign_key "sephcocco_lounge_product_likes", "sephcocco_lounge_products"
  add_foreign_key "sephcocco_lounge_product_likes", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_orders", "sephcocco_pharmacy_products"
  add_foreign_key "sephcocco_pharmacy_orders", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_product_likes", "sephcocco_pharmacy_products"
  add_foreign_key "sephcocco_pharmacy_product_likes", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_orders", "sephcocco_restaurant_products"
  add_foreign_key "sephcocco_restaurant_orders", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_product_likes", "sephcocco_restaurant_products"
  add_foreign_key "sephcocco_restaurant_product_likes", "sephcocco_users"
  add_foreign_key "sephcocco_users", "sephcocco_user_roles"
end
