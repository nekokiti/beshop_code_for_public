# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_05_112052) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_transfer_infos", force: :cascade do |t|
    t.bigint "account_type_id"
    t.bigint "company_id"
    t.string "bank_name", null: false
    t.string "branch_name", null: false
    t.string "company_name", null: false
    t.integer "account_number", null: false
    t.boolean "enable_flg", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_type_id"], name: "index_account_transfer_infos_on_account_type_id"
    t.index ["company_id"], name: "index_account_transfer_infos_on_company_id"
  end

  create_table "account_types", force: :cascade do |t|
    t.string "type_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "address_phases", id: :serial, force: :cascade do |t|
    t.integer "phase", default: 1
    t.integer "line_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_transfer_infos", force: :cascade do |t|
    t.boolean "enable_flg", default: false, null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_bank_transfer_infos_on_company_id"
  end

  create_table "business_hours", id: :serial, force: :cascade do |t|
    t.datetime "open_time"
    t.datetime "close_time"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cart_products", id: :serial, force: :cascade do |t|
    t.integer "cart_id"
    t.integer "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.integer "size_id"
    t.index ["cart_id"], name: "index_cart_products_on_cart_id"
    t.index ["product_id"], name: "index_cart_products_on_product_id"
  end

  create_table "carts", id: :serial, force: :cascade do |t|
    t.integer "line_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.string "cart_hash"
    t.datetime "deleted_at"
    t.boolean "chat_mode_flg", default: false
    t.index ["deleted_at"], name: "index_carts_on_deleted_at"
  end

  create_table "cash_on_delivery_infos", id: :serial, force: :cascade do |t|
    t.integer "price", default: 0
    t.integer "company_id"
    t.boolean "enable_flg", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alternative_name"
    t.index ["company_id"], name: "index_cash_on_delivery_infos_on_company_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name"
    t.string "unique_id"
    t.string "channel_access_token"
    t.string "channel_secret"
    t.integer "occupation_mst_id", default: 0
    t.index ["email"], name: "index_companies_on_email", unique: true
    t.index ["reset_password_token"], name: "index_companies_on_reset_password_token", unique: true
  end

  create_table "company_reserves", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.integer "enable_flg", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_reserves_on_company_id"
  end

  create_table "extra_messages", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.string "extra_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_extra_messages_on_company_id"
  end

  create_table "line_auth_infos", id: :serial, force: :cascade do |t|
    t.string "channel_id"
    t.string "channel_secret"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_line_auth_infos_on_company_id"
  end

  create_table "line_pay_infos", id: :serial, force: :cascade do |t|
    t.string "channel_id"
    t.string "channel_secret"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enable_flg", default: false, null: false
    t.index ["company_id"], name: "index_line_pay_infos_on_company_id"
  end

  create_table "line_users", id: :serial, force: :cascade do |t|
    t.string "line_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: ""
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "zip", default: "未設定"
    t.string "address_country", default: "未設定"
    t.string "address_state", default: "未設定"
    t.string "address_street", default: "未設定"
    t.string "first_name"
    t.string "last_name"
    t.string "address_city", default: "未設定"
    t.string "address_street_by_postal_code", default: ""
    t.boolean "address_set_flg", default: false
    t.string "tel"
    t.integer "company_id"
    t.string "room_number"
  end

  create_table "minimum_prices", id: :serial, force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "occupation_msts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_products", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "size_id"
    t.string "product_name"
    t.integer "product_price"
    t.string "size_name"
    t.string "jancode"
    t.integer "quantity"
    t.boolean "coupon_flg", default: false
    t.index ["order_id"], name: "index_order_products_on_order_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "line_user_id", null: false
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "txn_id"
    t.integer "total_price"
    t.integer "company_id"
    t.integer "cart_id"
    t.string "zip"
    t.string "address_country"
    t.string "address_state"
    t.string "address_street"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "address_city"
    t.integer "tax"
    t.integer "mc_shipping"
    t.integer "mc_handling"
    t.string "random_order_id"
    t.string "payment_method"
    t.string "tel"
    t.integer "discount", default: 0
    t.integer "cash_on_delivery_price", default: 0
    t.string "room_number", default: "未設定"
  end

  create_table "otorioki_times", id: :serial, force: :cascade do |t|
    t.integer "min_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
  end

  create_table "paidy_captures", force: :cascade do |t|
    t.string "capture_id"
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_paidy_captures_on_order_id"
  end

  create_table "paidy_infos", force: :cascade do |t|
    t.bigint "company_id"
    t.string "public_key"
    t.string "secret_key"
    t.boolean "enable_flg", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_paidy_infos_on_company_id"
  end

  create_table "pay_pay_infos", force: :cascade do |t|
    t.string "client_id"
    t.string "client_secret"
    t.string "merchant_id"
    t.boolean "enable_flg", default: false, null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_pay_pay_infos_on_company_id"
  end

  create_table "payers", id: :serial, force: :cascade do |t|
    t.string "zip"
    t.string "address_country"
    t.string "address_state"
    t.string "address_street"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "payer_id"
    t.integer "line_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "paypal_infos", id: :serial, force: :cascade do |t|
    t.string "paypal_credential_username"
    t.string "paypal_credential_password"
    t.string "paypal_credential_signature"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_id"
    t.boolean "enable_flg", default: false, null: false
  end

  create_table "products", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.string "image_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description", limit: 60
    t.integer "price", null: false
    t.integer "quantity", default: 0
    t.integer "company_id"
    t.datetime "deleted_at"
    t.boolean "has_size", default: false
    t.boolean "recommend_flg", default: false
    t.boolean "otorioki_flg", default: false
    t.string "movie_path"
    t.boolean "reduction_tax", default: false
    t.string "jancode"
    t.boolean "disp_inventory_flg", default: false
    t.boolean "coupon_flg", default: false
    t.boolean "no_extra_fee", default: false
    t.boolean "tax_free_flg", default: false
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
  end

  create_table "reserve_details", id: :serial, force: :cascade do |t|
    t.integer "line_user_id"
    t.integer "order_id"
    t.integer "cart_id"
    t.date "take_over_date"
    t.time "take_over_time_from"
    t.time "take_over_time_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_reserve_details_on_cart_id"
    t.index ["line_user_id"], name: "index_reserve_details_on_line_user_id"
    t.index ["order_id"], name: "index_reserve_details_on_order_id"
  end

  create_table "reserve_time_as", id: :serial, force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.time "from_time_1"
    t.time "end_time_1"
    t.time "from_time_2"
    t.time "end_time_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_reserve_id"
    t.index ["company_reserve_id"], name: "index_reserve_time_as_on_company_reserve_id"
  end

  create_table "reserve_time_bs", id: :serial, force: :cascade do |t|
    t.integer "days_after_from"
    t.integer "days_after_to"
    t.time "from_time_1"
    t.time "end_time_1"
    t.time "from_time_2"
    t.time "end_time_2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_reserve_id"
    t.index ["company_reserve_id"], name: "index_reserve_time_bs_on_company_reserve_id"
  end

  create_table "shipping_companies", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.string "shipping_company_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_shipping_companies_on_company_id"
  end

  create_table "shipping_infos", id: :serial, force: :cascade do |t|
    t.datetime "shipping_day", null: false
    t.string "shipping_number"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shipping_company_id"
    t.index ["order_id"], name: "index_shipping_infos_on_order_id"
    t.index ["shipping_company_id"], name: "index_shipping_infos_on_shipping_company_id"
  end

  create_table "shippings", id: :serial, force: :cascade do |t|
    t.integer "shipping_fee", default: 0
    t.integer "extra_fee", default: 0
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "size_products", id: :serial, force: :cascade do |t|
    t.integer "size_id"
    t.integer "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity", default: 0
    t.index ["product_id"], name: "index_size_products_on_product_id"
    t.index ["size_id"], name: "index_size_products_on_size_id"
  end

  create_table "sizes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sticon_products", id: :serial, force: :cascade do |t|
    t.integer "sticon_id"
    t.integer "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sticon_products_on_product_id"
    t.index ["sticon_id"], name: "index_sticon_products_on_sticon_id"
  end

  create_table "sticoncategories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sticonpackages", id: :serial, force: :cascade do |t|
    t.integer "package_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sticoncategory_id"
  end

  create_table "sticons", id: :serial, force: :cascade do |t|
    t.integer "sticon_id"
    t.integer "sticonpackage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_taggings_on_product_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "tag_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.datetime "deleted_at"
    t.string "image_path"
    t.string "url"
    t.index ["deleted_at"], name: "index_tags_on_deleted_at"
    t.index ["tag_name", "company_id"], name: "index_tags_on_tag_name_and_company_id", unique: true, where: "(deleted_at IS NULL)"
  end

  create_table "take_over_times", id: :serial, force: :cascade do |t|
    t.datetime "take_over_time", null: false
    t.integer "cart_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_id"
    t.index ["cart_id"], name: "index_take_over_times_on_cart_id"
  end

  create_table "user_keywords", id: :serial, force: :cascade do |t|
    t.string "keyword", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "counts", default: 1
  end

  add_foreign_key "account_transfer_infos", "account_types"
  add_foreign_key "account_transfer_infos", "companies"
  add_foreign_key "bank_transfer_infos", "companies"
  add_foreign_key "cart_products", "carts"
  add_foreign_key "cart_products", "products"
  add_foreign_key "cash_on_delivery_infos", "companies"
  add_foreign_key "company_reserves", "companies"
  add_foreign_key "extra_messages", "companies"
  add_foreign_key "line_auth_infos", "companies"
  add_foreign_key "line_pay_infos", "companies"
  add_foreign_key "order_products", "orders"
  add_foreign_key "paidy_captures", "orders"
  add_foreign_key "paidy_infos", "companies"
  add_foreign_key "pay_pay_infos", "companies"
  add_foreign_key "reserve_details", "carts"
  add_foreign_key "reserve_details", "line_users"
  add_foreign_key "reserve_details", "orders"
  add_foreign_key "reserve_time_as", "company_reserves", column: "company_reserve_id"
  add_foreign_key "reserve_time_bs", "company_reserves", column: "company_reserve_id"
  add_foreign_key "shipping_companies", "companies"
  add_foreign_key "shipping_infos", "orders"
  add_foreign_key "shipping_infos", "shipping_companies"
  add_foreign_key "size_products", "products"
  add_foreign_key "size_products", "sizes"
  add_foreign_key "sticon_products", "products"
  add_foreign_key "sticon_products", "sticons"
  add_foreign_key "taggings", "products"
  add_foreign_key "taggings", "tags"
  add_foreign_key "take_over_times", "carts"
end
