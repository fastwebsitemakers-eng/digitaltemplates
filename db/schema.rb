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

ActiveRecord::Schema[8.1].define(version: 2026_09_25_180806) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "content_items", force: :cascade do |t|
    t.string "kind", null: false
    t.string "title", null: false
    t.text "body"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_content_items_on_kind"
  end

  create_table "purchases", force: :cascade do |t|
    t.string "email", null: false
    t.string "product_name", null: false
    t.string "token", null: false
    t.string "stripe_session_id", null: false
    t.string "stripe_payment_intent_id"
    t.integer "amount_paid", null: false
    t.string "currency", default: "usd", null: false
    t.string "status", default: "paid", null: false
    t.datetime "download_expires_at"
    t.integer "download_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_purchases_on_email"
    t.index ["stripe_session_id"], name: "index_purchases_on_stripe_session_id", unique: true
    t.index ["token"], name: "index_purchases_on_token", unique: true
  end

  create_table "site_settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_site_settings_on_key", unique: true
  end
end
