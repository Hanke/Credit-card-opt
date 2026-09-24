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

ActiveRecord::Schema[8.1].define(version: 2026_09_24_190004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "credit_cards", force: :cascade do |t|
    t.string "name", null: false
    t.string "issuer", null: false
    t.string "network"
    t.integer "annual_fee_cents", default: 0, null: false
    t.bigint "reward_currency_id", null: false
    t.decimal "base_earn_rate", precision: 6, scale: 4, default: "0.0", null: false
    t.boolean "active", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issuer"], name: "index_credit_cards_on_issuer"
    t.index ["reward_currency_id"], name: "index_credit_cards_on_reward_currency_id"
  end

  create_table "reward_currencies", force: :cascade do |t|
    t.citext "name", null: false
    t.decimal "cents_per_point", precision: 8, scale: 4, null: false, comment: "Value of one point in cents: 1.0 = 1 cent/point, Aeroplan 1.5, PC Optimum 0.1. value_cents = points * cents_per_point."
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_reward_currencies_on_name", unique: true
  end

  create_table "reward_rules", force: :cascade do |t|
    t.bigint "credit_card_id", null: false
    t.string "category", null: false
    t.decimal "earning_rate", precision: 6, scale: 4, null: false
    t.integer "spend_cap_cents"
    t.date "effective_from", null: false
    t.date "effective_to"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_card_id", "category", "effective_from"], name: "index_reward_rules_on_card_category_effective_from"
  end

  create_table "user_cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "credit_card_id", null: false
    t.datetime "added_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_card_id"], name: "index_user_cards_on_credit_card_id"
    t.index ["user_id", "credit_card_id"], name: "index_user_cards_on_user_id_and_credit_card_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.citext "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "credit_cards", "reward_currencies"
  add_foreign_key "reward_rules", "credit_cards"
  add_foreign_key "user_cards", "credit_cards"
  add_foreign_key "user_cards", "users"
end
