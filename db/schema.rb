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

ActiveRecord::Schema.define(version: 20171227220333) do

  create_table "archive_jobs", force: :cascade do |t|
    t.string   "archive_name", limit: 255
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "status",       limit: 255
    t.text     "message",      limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "archives", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "base_url",         limit: 255
    t.string   "send_frequency",   limit: 255
    t.datetime "last_archived_at"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "enabled",                      default: false
  end

  create_table "influxdb_tags", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "value",         limit: 255
    t.integer  "instrument_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "influxdb_tags", ["instrument_id"], name: "index_influxdb_tags_on_instrument_id", using: :btree

  create_table "instruments", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "site_id",             limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "display_points",      limit: 4,     default: 120
    t.integer  "sample_rate_seconds", limit: 4,     default: 60
    t.text     "last_url",            limit: 65535
    t.text     "description",         limit: 65535
    t.integer  "plot_offset_value",   limit: 4,     default: 1
    t.string   "plot_offset_units",   limit: 255,   default: "weeks"
    t.integer  "topic_category_id",   limit: 4
    t.integer  "cuahsi_method_id",    limit: 4
    t.boolean  "is_active",                         default: true
  end

  add_index "instruments", ["site_id"], name: "index_instruments_on_site_id", using: :btree

  create_table "measured_properties", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "label",      limit: 255
    t.string   "url",        limit: 255
    t.text     "definition", limit: 65535
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "source",     limit: 255,   default: "SensorML"
  end

  create_table "measurements", force: :cascade do |t|
    t.integer  "instrument_id", limit: 4
    t.string   "parameter",     limit: 255
    t.float    "value",         limit: 24
    t.string   "unit",          limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.datetime "measured_at"
    t.boolean  "test",                      default: false, null: false
  end

  add_index "measurements", ["instrument_id"], name: "index_measurements_on_instrument_id", using: :btree
  add_index "measurements", ["measured_at"], name: "index_measurements_on_measured_at", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "project",                  limit: 255
    t.string   "affiliation",              limit: 255
    t.text     "description",              limit: 65535
    t.binary   "logo",                     limit: 16777215
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.string   "timezone",                 limit: 255
    t.boolean  "secure_administration",                     default: false
    t.boolean  "secure_data_viewing",                       default: true
    t.boolean  "secure_data_download",                      default: true
    t.boolean  "secure_data_entry",                         default: true
    t.string   "data_entry_key",           limit: 255
    t.string   "google_maps_key",          limit: 255,      default: "none"
    t.string   "page_title",               limit: 255,      default: "CHORDS Portal"
    t.text     "doi",                      limit: 65535
    t.string   "contact_name",             limit: 255,      default: "Contact Name",         null: false
    t.string   "contact_phone",            limit: 255,      default: "Contact Phone",        null: false
    t.string   "contact_email",            limit: 255,      default: "Contact Email",        null: false
    t.string   "contact_address",          limit: 255,      default: "Contact Address",      null: false
    t.string   "contact_city",             limit: 255,      default: "Contact City",         null: false
    t.string   "contact_state",            limit: 255,      default: "Contact State",        null: false
    t.string   "contact_country",          limit: 255,      default: "Contact Country",      null: false
    t.string   "contact_zipcode",          limit: 255,      default: "Contact Zipcode",      null: false
    t.string   "domain_name",              limit: 255,      default: "example.chordsrt.com", null: false
    t.integer  "cuahsi_source_id",         limit: 4
    t.string   "unit_source",              limit: 255,      default: "CUAHSI"
    t.string   "measured_property_source", limit: 255,      default: "SensorML"
  end

  create_table "site_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "definition", limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "sites", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.decimal  "lat",                            precision: 12, scale: 9
    t.decimal  "lon",                            precision: 12, scale: 9
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.text     "description",      limit: 65535
    t.decimal  "elevation",                      precision: 12, scale: 6, default: 0.0
    t.integer  "site_type_id",     limit: 4
    t.integer  "cuahsi_site_code", limit: 4
    t.integer  "cuahsi_site_id",   limit: 4
  end

  add_index "sites", ["site_type_id"], name: "index_sites_on_site_type_id", using: :btree

  create_table "topic_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "definition", limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "units", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "abbreviation", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "id_num",       limit: 4
    t.string   "unit_type",    limit: 255
    t.string   "source",       limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "is_administrator",                   default: false
    t.boolean  "is_data_viewer",                     default: true
    t.boolean  "is_data_downloader",                 default: true
    t.string   "api_key",                limit: 255
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vars", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.integer  "instrument_id",        limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "shortname",            limit: 255
    t.string   "units",                limit: 255, default: "C",       null: false
    t.integer  "measured_property_id", limit: 4,   default: 795,       null: false
    t.float    "minimum_plot_value",   limit: 24
    t.float    "maximum_plot_value",   limit: 24
    t.integer  "unit_id",              limit: 4,   default: 1
    t.integer  "cuahsi_variable_id",   limit: 4
    t.string   "general_category",     limit: 255, default: "Unknown"
  end

  add_index "vars", ["instrument_id"], name: "index_vars_on_instrument_id", using: :btree
  add_index "vars", ["measured_property_id"], name: "index_vars_on_measured_property_id", using: :btree
  add_index "vars", ["unit_id"], name: "index_vars_on_unit_id", using: :btree

  add_foreign_key "instruments", "sites"
  add_foreign_key "measurements", "instruments"
  add_foreign_key "sites", "site_types"
  add_foreign_key "vars", "instruments"
end
