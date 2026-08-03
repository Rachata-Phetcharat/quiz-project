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

ActiveRecord::Schema[8.1].define(version: 2026_08_03_081104) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", id: :serial, force: :cascade do |t|
    t.date "booking_date", null: false
    t.datetime "cancelled_at", precision: nil
    t.integer "court_id"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.integer "customer_id"
    t.time "end_time", null: false
    t.decimal "penalty_amount", precision: 10, scale: 2, default: "0.0"
    t.string "phonenumber", limit: 20
    t.decimal "price", precision: 10, scale: 2, null: false
    t.time "start_time", null: false
    t.string "status", limit: 50, default: "pending"
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "courts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.date "maintenance_date"
    t.string "name", limit: 255, null: false
    t.string "status", limit: 50, default: "open"
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "customers", id: :serial, force: :cascade do |t|
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.string "name", limit: 255, null: false
    t.string "role", limit: 50, default: "customer"
    t.string "u_id", limit: 100, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }

    t.unique_constraint ["u_id"], name: "customers_u_id_key"
  end

  add_foreign_key "bookings", "courts", name: "bookings_court_id_fkey", on_delete: :cascade
  add_foreign_key "bookings", "customers", name: "bookings_customer_id_fkey", on_delete: :cascade
end
