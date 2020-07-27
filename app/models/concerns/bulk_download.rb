class BulkDownload

  def self.site_fields
    site_fields = {
      'id'              => true,
      'name'            => true,
      'lat'             => true,
      'lon'             => true,
      'elevation'       => true,
      'site_type.name'  => false,
    }

    # Sites
    # t.string "name"
    # t.decimal "lat", precision: 12, scale: 9
    # t.decimal "lon", precision: 12, scale: 9
    # t.decimal "elevation", precision: 12, scale: 6, default: "0.0"
    # t.integer "site_type_id"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    # t.text "description"

    # Site Types
    # t.string "name"
    #   t.text "definition"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false


    return site_fields
  end

def self.instrument_fields
    instrument_fields = {
      'id'                  => true,
      'name'                => true,
      'sensor_id'           => true,
      'display_points'      => false,
      'sample_rate_seconds' => false,

      'topic_category.name' => false,
    }

    # Instruments
    # t.string "name"
    # t.string "sensor_id"
    # t.integer "display_points", default: 120
    # t.integer "sample_rate_seconds", default: 60
    #   t.integer "site_id"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    #   t.text "last_url"
    #   t.text "description"
    #   t.integer "plot_offset_value", default: 1
    #   t.string "plot_offset_units", default: "weeks"
    #   t.integer "topic_category_id"
    #   t.boolean "is_active", default: true
    #   t.bigint "measurement_count", default: 0, null: false
    #   t.bigint "measurement_test_count", default: 0, null: false

    # Topic Category
    # t.string "name"
    #   t.text "definition"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false

    return instrument_fields
  end




  def self.var_fields
    var_fields = {
      'name' =>                   true,
      'shortname'                 => true,
      'general_category'          => true,
      'minimum_plot_value'        => false,
      'maximum_plot_value'        => false,

      'measured_property.name'    => false,
      'measured_property.label'   => false,
      'measured_property.url'     => false,
      'measured_property.source'  => false,

      'unit.name'                 => true,
      'unit.abbreviation'         => true,
      'unit.id_num'               => false,
      'unit.unit_type'            => false,
      'unit.source'               => false,
    }

    # Vars
    # t.string "name"
    # t.integer "instrument_id"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.string "shortname"
    # t.integer "measured_property_id", default: 795, null: false
    # t.float "minimum_plot_value"
    # t.float "maximum_plot_value"
    # t.integer "unit_id", default: 1
    # t.string "general_category", default: "Unknown"

    # Measured Properties
    # t.string "name"
    # t.string "label"
    # t.string "url"
    # t.text "definition"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.string "source", default: "SensorML"

    # Units
    # t.string "name"
    # t.string "abbreviation"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.integer "id_num"
    # t.string "unit_type"
    # t.string "source"

    return var_fields
  end
end
