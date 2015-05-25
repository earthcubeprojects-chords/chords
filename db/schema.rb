# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150525034207) do

  create_table "instruments", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.integer  "site_id",                limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "display_points",         limit: 4,   default: 20
    t.integer  "seconds_before_timeout", limit: 4,   default: 5
  end

  add_index "instruments", ["site_id"], name: "index_instruments_on_site_id", using: :btree

  create_table "measurements", force: :cascade do |t|
    t.integer  "instrument_id", limit: 4
    t.string   "parameter",     limit: 255
    t.float    "value",         limit: 24
    t.string   "unit",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "measurements", ["instrument_id"], name: "index_measurements_on_instrument_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "project",     limit: 255
    t.string   "affiliation", limit: 255
    t.string   "description", limit: 1000
    t.binary   "logo",        limit: 16777215
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "sites", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.float    "lat",        limit: 24
    t.float    "lon",        limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_foreign_key "instruments", "sites"
  add_foreign_key "measurements", "instruments"
end
