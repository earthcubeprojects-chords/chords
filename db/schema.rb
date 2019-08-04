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

ActiveRecord::Schema.define(version: 2019_08_02_055026) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "archive_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "archive_name"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string "status"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "archives", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "base_url"
    t.string "send_frequency"
    t.datetime "last_archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: false
  end

  create_table "images", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "influxdb_tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.bigint "instrument_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id"], name: "index_influxdb_tags_on_instrument_id"
  end

  create_table "input_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.float "origin_lat", default: 32.4921
    t.float "origin_lon", default: -96.9973
    t.datetime "scanned_at"
    t.text "header_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instruments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_points", default: 120
    t.integer "sample_rate_seconds", default: 60
    t.text "last_url"
    t.text "description"
    t.integer "plot_offset_value", default: 1
    t.string "plot_offset_units", default: "weeks"
    t.integer "topic_category_id"
    t.boolean "is_active", default: true
    t.string "sensor_id"
    t.bigint "measurement_count", default: 0, null: false
    t.bigint "measurement_test_count", default: 0, null: false
    t.index ["sensor_id"], name: "index_instruments_on_sensor_id", unique: true
    t.index ["site_id"], name: "index_instruments_on_site_id"
  end

  create_table "linked_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "name", null: false
    t.text "description", null: false
    t.text "keywords", null: false
    t.string "dataset_url"
    t.string "license"
    t.string "doi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "measured_properties", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "label"
    t.string "url"
    t.text "definition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source", default: "SensorML"
  end

  create_table "netcdf_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "project"
    t.string "affiliation"
    t.text "description"
    t.binary "logo", limit: 16777215
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone"
    t.boolean "secure_administration", default: true
    t.boolean "secure_data_viewing", default: false
    t.boolean "secure_data_download", default: true
    t.boolean "secure_data_entry", default: true
    t.string "data_entry_key"
    t.string "page_title", default: "CHORDS Portal"
    t.text "doi"
    t.string "contact_name", default: "Contact Name", null: false
    t.string "contact_phone", default: "Contact Phone", null: false
    t.string "contact_email", default: "Contact Email", null: false
    t.string "contact_address", default: "Contact Address", null: false
    t.string "contact_city", default: "Contact City", null: false
    t.string "contact_state", default: "Contact State", null: false
    t.string "contact_country", default: "Contact Country", null: false
    t.string "contact_zipcode", default: "Contact Zipcode", null: false
    t.string "domain_name", default: "example.chordsrt.com", null: false
    t.string "unit_source", default: "CUAHSI"
    t.string "measured_property_source", default: "SensorML"
    t.string "data_archive_url"
    t.integer "max_download_points", default: 100000
  end

  create_table "radar_data", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "sampled_at"
    t.float "origin_lat", default: 40.123
    t.float "origin_lon", default: -101.123
    t.text "header_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "site_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "definition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.decimal "lat", precision: 12, scale: 9
    t.decimal "lon", precision: 12, scale: 9
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.decimal "elevation", precision: 12, scale: 6, default: "0.0"
    t.bigint "site_type_id"
    t.index ["site_type_id"], name: "index_sites_on_site_type_id"
  end

  create_table "topic_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "definition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "id_num"
    t.string "unit_type"
    t.string "source"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_key"
    t.integer "roles_mask"
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vars", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.bigint "instrument_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shortname"
    t.bigint "measured_property_id", default: 795, null: false
    t.float "minimum_plot_value"
    t.float "maximum_plot_value"
    t.integer "unit_id", default: 1
    t.string "general_category", default: "Unknown"
    t.index ["instrument_id"], name: "index_vars_on_instrument_id"
    t.index ["measured_property_id"], name: "index_vars_on_measured_property_id"
    t.index ["unit_id"], name: "index_vars_on_unit_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "instruments", "sites"
  add_foreign_key "sites", "site_types"
  add_foreign_key "vars", "instruments"
end
