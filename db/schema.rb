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

ActiveRecord::Schema[7.2].define(version: 2025_09_08_113731) do
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

  create_table "rider_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "rider_id", null: false
    t.decimal "latitude", precision: 10, scale: 8, null: false
    t.decimal "longitude", precision: 11, scale: 8, null: false
    t.decimal "accuracy", precision: 5, scale: 2
    t.string "outlet_type"
    t.datetime "timestamp", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["outlet_type"], name: "index_rider_locations_on_outlet_type"
    t.index ["rider_id", "active"], name: "index_rider_locations_on_rider_id_and_active"
    t.index ["rider_id"], name: "index_rider_locations_on_rider_id"
    t.index ["timestamp"], name: "index_rider_locations_on_timestamp"
  end

  create_table "sephcocco_lounge_admin_activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.string "activity_type"
    t.string "activity_name"
    t.string "activity_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "index_sephcocco_lounge_admin_activities_on_sephcocco_user_id"
  end

  create_table "sephcocco_lounge_admin_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.string "action_type", null: false
    t.string "action_id"
    t.string "message", null: false
    t.boolean "viewed", default: false, null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "idx_on_sephcocco_user_id_9f7b5fc819"
  end

  create_table "sephcocco_lounge_faq_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.boolean "visibility", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sephcocco_lounge_faqs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "answer"
    t.boolean "visibility", default: false, null: false
    t.integer "position", default: 0, null: false
    t.jsonb "update_history", default: {}, null: false
    t.uuid "sephcocco_lounge_faq_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_lounge_faq_category_id"], name: "idx_on_sephcocco_lounge_faq_category_id_07b654db6a"
  end

  create_table "sephcocco_lounge_messages", force: :cascade do |t|
    t.string "sephcocco_lounge_products_type"
    t.uuid "sephcocco_lounge_products_id"
    t.uuid "sephcocco_user_id", null: false
    t.jsonb "chats", default: []
    t.jsonb "status_history", default: [], array: true
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_lounge_products_type", "sephcocco_lounge_products_id"], name: "index_sephcocco_lounge_messages_on_sephcocco_lounge_products"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_lounge_messages_on_sephcocco_user_id"
  end

  create_table "sephcocco_lounge_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_lounge_product_id", null: false
    t.uuid "sephcocco_user_id", null: false
    t.string "status", default: "pending", null: false
    t.string "stages", default: [], array: true
    t.string "current_stage", null: false
    t.string "order_number", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.decimal "total_cost", precision: 10, scale: 2, null: false
    t.string "address"
    t.string "phone_number"
    t.text "additional_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "sephcocco_lounge_payment_id"
    t.index ["sephcocco_lounge_payment_id"], name: "index_sephcocco_lounge_orders_on_sephcocco_lounge_payment_id"
    t.index ["sephcocco_lounge_product_id"], name: "index_sephcocco_lounge_orders_on_sephcocco_lounge_product_id"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_lounge_orders_on_sephcocco_user_id"
  end

  create_table "sephcocco_lounge_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.jsonb "status_history", default: []
    t.decimal "amount", precision: 10, scale: 2
    t.string "payment_method"
    t.string "transaction_id"
    t.jsonb "orders", default: []
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
    t.decimal "price", precision: 16, scale: 2, default: "0.0", null: false
    t.integer "amount_in_stock", default: 0, null: false
    t.string "short_description"
    t.text "long_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "main_image_url"
    t.string "other_image_urls", default: [], array: true
    t.decimal "discount_price", precision: 16, scale: 2, default: "0.0", null: false
    t.index ["name"], name: "index_sephcocco_lounge_products_on_name", unique: true
  end

  create_table "sephcocco_lounge_shippings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tracking_number"
    t.string "status"
    t.datetime "datetime_delivered"
    t.boolean "dispatching", default: false
    t.uuid "sephcocco_lounge_order_id", null: false
    t.uuid "rider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rider_id"], name: "index_sephcocco_lounge_shippings_on_rider_id"
    t.index ["sephcocco_lounge_order_id"], name: "index_sephcocco_lounge_shippings_on_sephcocco_lounge_order_id"
  end

  create_table "sephcocco_outlets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sephcocco_outlets_users", id: false, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.uuid "sephcocco_outlet_id", null: false
    t.index ["sephcocco_user_id", "sephcocco_outlet_id"], name: "index_outlets_users_on_user_id_and_outlet_id", unique: true
  end

  create_table "sephcocco_pharmacy_admin_activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.string "activity_type"
    t.string "activity_name"
    t.string "activity_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "index_sephcocco_pharmacy_admin_activities_on_sephcocco_user_id"
  end

  create_table "sephcocco_pharmacy_admin_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.string "action_type", null: false
    t.string "action_id"
    t.string "message", null: false
    t.boolean "viewed", default: false, null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "idx_on_sephcocco_user_id_febb8e25ad"
  end

  create_table "sephcocco_pharmacy_faq_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.boolean "visibility", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sephcocco_pharmacy_faqs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "answer"
    t.boolean "visibility", default: false, null: false
    t.integer "position", default: 0, null: false
    t.jsonb "update_history", default: {}, null: false
    t.uuid "sephcocco_pharmacy_faq_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_pharmacy_faq_category_id"], name: "idx_on_sephcocco_pharmacy_faq_category_id_db35bfba86"
  end

  create_table "sephcocco_pharmacy_messages", force: :cascade do |t|
    t.string "sephcocco_pharmacy_products_type"
    t.uuid "sephcocco_pharmacy_products_id"
    t.uuid "sephcocco_user_id", null: false
    t.jsonb "chats", default: []
    t.jsonb "status_history", default: [], array: true
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_pharmacy_products_type", "sephcocco_pharmacy_products_id"], name: "pharmacy_messages_on_sephcocco_pharmacy_products"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_pharmacy_messages_on_sephcocco_user_id"
  end

  create_table "sephcocco_pharmacy_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_pharmacy_product_id", null: false
    t.uuid "sephcocco_user_id", null: false
    t.string "status", default: "pending", null: false
    t.string "current_stage", null: false
    t.string "order_number", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.decimal "total_cost", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stages", default: []
    t.uuid "sephcocco_pharmacy_payment_id"
    t.index ["sephcocco_pharmacy_payment_id"], name: "idx_on_sephcocco_pharmacy_payment_id_1ac640bb64"
    t.index ["sephcocco_pharmacy_product_id"], name: "idx_on_sephcocco_pharmacy_product_id_87c79f77bf"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_pharmacy_orders_on_sephcocco_user_id"
  end

  create_table "sephcocco_pharmacy_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.jsonb "status_history", default: []
    t.decimal "amount", precision: 10, scale: 2
    t.string "payment_method"
    t.string "transaction_id"
    t.jsonb "orders", default: []
    t.uuid "sephcocco_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "index_sephcocco_pharmacy_payments_on_sephcocco_user_id"
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
    t.decimal "price", precision: 16, scale: 2, default: "0.0", null: false
    t.integer "amount_in_stock", default: 0, null: false
    t.string "short_description"
    t.text "long_description"
    t.integer "likes", default: 0, null: false
    t.boolean "visible", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_urls", default: [], array: true
    t.string "main_image_url"
    t.string "other_image_urls", default: [], array: true
    t.decimal "discount_price", precision: 16, scale: 2, default: "0.0", null: false
    t.index ["name"], name: "index_sephcocco_pharmacy_products_on_name", unique: true
  end

  create_table "sephcocco_pharmacy_shippings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tracking_number"
    t.string "status"
    t.datetime "datetime_delivered"
    t.boolean "dispatching", default: false
    t.uuid "sephcocco_pharmacy_order_id", null: false
    t.uuid "rider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rider_id"], name: "index_sephcocco_pharmacy_shippings_on_rider_id"
    t.index ["sephcocco_pharmacy_order_id"], name: "idx_on_sephcocco_pharmacy_order_id_552de683f6"
  end

  create_table "sephcocco_restaurant_admin_activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.string "activity_type"
    t.string "activity_name"
    t.string "activity_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "idx_on_sephcocco_user_id_c992d745ab"
  end

  create_table "sephcocco_restaurant_admin_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_user_id", null: false
    t.string "action_type", null: false
    t.string "action_id"
    t.string "message", null: false
    t.boolean "viewed", default: false, null: false
    t.boolean "visible", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "idx_on_sephcocco_user_id_2820f90946"
  end

  create_table "sephcocco_restaurant_faq_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.boolean "visibility", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sephcocco_restaurant_faqs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "answer"
    t.boolean "visibility", default: false, null: false
    t.integer "position", default: 0, null: false
    t.jsonb "update_history", default: {}, null: false
    t.uuid "sephcocco_restaurant_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_restaurant_category_id"], name: "idx_on_sephcocco_restaurant_category_id_0e2ba23b6a"
  end

  create_table "sephcocco_restaurant_messages", force: :cascade do |t|
    t.string "sephcocco_restaurant_products_type"
    t.uuid "sephcocco_restaurant_products_id"
    t.uuid "sephcocco_user_id", null: false
    t.jsonb "chats", default: []
    t.jsonb "status_history", default: [], array: true
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_restaurant_products_type", "sephcocco_restaurant_products_id"], name: "restaurant_messages_on_sephcocco_restaurant_products"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_restaurant_messages_on_sephcocco_user_id"
  end

  create_table "sephcocco_restaurant_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sephcocco_restaurant_product_id", null: false
    t.uuid "sephcocco_user_id", null: false
    t.string "status", default: "pending", null: false
    t.string "current_stage", null: false
    t.string "order_number", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 10, scale: 2, null: false
    t.decimal "total_cost", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "stages", default: []
    t.uuid "sephcocco_restaurant_payment_id"
    t.index ["sephcocco_restaurant_payment_id"], name: "idx_on_sephcocco_restaurant_payment_id_b41ca0049c"
    t.index ["sephcocco_restaurant_product_id"], name: "idx_on_sephcocco_restaurant_product_id_862b37aba9"
    t.index ["sephcocco_user_id"], name: "index_sephcocco_restaurant_orders_on_sephcocco_user_id"
  end

  create_table "sephcocco_restaurant_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.jsonb "status_history", default: []
    t.decimal "amount", precision: 10, scale: 2
    t.string "payment_method"
    t.string "transaction_id"
    t.jsonb "orders", default: []
    t.uuid "sephcocco_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sephcocco_user_id"], name: "index_sephcocco_restaurant_payments_on_sephcocco_user_id"
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
    t.decimal "price", precision: 16, scale: 2, default: "0.0", null: false
    t.integer "amount_in_stock", default: 0, null: false
    t.string "short_description"
    t.text "long_description"
    t.integer "likes", default: 0, null: false
    t.boolean "visible", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_urls", default: [], array: true
    t.string "main_image_url"
    t.string "other_image_urls", default: [], array: true
    t.decimal "discount_price", precision: 16, scale: 2, default: "0.0", null: false
    t.index ["name"], name: "index_sephcocco_restaurant_products_on_name", unique: true
  end

  create_table "sephcocco_restaurant_shippings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "tracking_number"
    t.string "status"
    t.datetime "datetime_delivered"
    t.boolean "dispatching", default: false
    t.uuid "sephcocco_restaurant_order_id", null: false
    t.uuid "rider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rider_id"], name: "index_sephcocco_restaurant_shippings_on_rider_id"
    t.index ["sephcocco_restaurant_order_id"], name: "idx_on_sephcocco_restaurant_order_id_2b91f3bddc"
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
    t.string "password_digest"
    t.boolean "suspended", default: false
    t.datetime "last_login_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "payment_ref", default: "0001"
    t.string "email_confirmation_token"
    t.datetime "email_confirmation_sent_at"
    t.boolean "email_confirmed", default: false
    t.index ["email"], name: "index_sephcocco_users_on_email", unique: true
    t.index ["sephcocco_user_role_id"], name: "index_sephcocco_users_on_sephcocco_user_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "rider_locations", "sephcocco_users", column: "rider_id"
  add_foreign_key "sephcocco_lounge_admin_activities", "sephcocco_users"
  add_foreign_key "sephcocco_lounge_admin_notifications", "sephcocco_users"
  add_foreign_key "sephcocco_lounge_faqs", "sephcocco_lounge_faq_categories"
  add_foreign_key "sephcocco_lounge_messages", "sephcocco_users"
  add_foreign_key "sephcocco_lounge_orders", "sephcocco_lounge_payments"
  add_foreign_key "sephcocco_lounge_orders", "sephcocco_lounge_products"
  add_foreign_key "sephcocco_lounge_orders", "sephcocco_users"
  add_foreign_key "sephcocco_lounge_payments", "sephcocco_users"
  add_foreign_key "sephcocco_lounge_product_likes", "sephcocco_lounge_products"
  add_foreign_key "sephcocco_lounge_product_likes", "sephcocco_users"
  add_foreign_key "sephcocco_lounge_shippings", "sephcocco_lounge_orders"
  add_foreign_key "sephcocco_lounge_shippings", "sephcocco_users", column: "rider_id"
  add_foreign_key "sephcocco_outlets_users", "sephcocco_outlets"
  add_foreign_key "sephcocco_outlets_users", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_admin_activities", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_admin_notifications", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_faqs", "sephcocco_pharmacy_faq_categories"
  add_foreign_key "sephcocco_pharmacy_messages", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_orders", "sephcocco_pharmacy_payments"
  add_foreign_key "sephcocco_pharmacy_orders", "sephcocco_pharmacy_products"
  add_foreign_key "sephcocco_pharmacy_orders", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_payments", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_product_likes", "sephcocco_pharmacy_products"
  add_foreign_key "sephcocco_pharmacy_product_likes", "sephcocco_users"
  add_foreign_key "sephcocco_pharmacy_shippings", "sephcocco_pharmacy_orders"
  add_foreign_key "sephcocco_pharmacy_shippings", "sephcocco_users", column: "rider_id"
  add_foreign_key "sephcocco_restaurant_admin_activities", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_admin_notifications", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_faqs", "sephcocco_restaurant_faq_categories", column: "sephcocco_restaurant_category_id"
  add_foreign_key "sephcocco_restaurant_messages", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_orders", "sephcocco_restaurant_payments"
  add_foreign_key "sephcocco_restaurant_orders", "sephcocco_restaurant_products"
  add_foreign_key "sephcocco_restaurant_orders", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_payments", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_product_likes", "sephcocco_restaurant_products"
  add_foreign_key "sephcocco_restaurant_product_likes", "sephcocco_users"
  add_foreign_key "sephcocco_restaurant_shippings", "sephcocco_restaurant_orders"
  add_foreign_key "sephcocco_restaurant_shippings", "sephcocco_users", column: "rider_id"
  add_foreign_key "sephcocco_users", "sephcocco_user_roles"
end
