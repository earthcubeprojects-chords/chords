class BulkDownload
  attr_accessor :random_job_id   # Define a unique string for this job
  attr_accessor :creation_time   # Time to be used in file naming
  attr_accessor :profile         # The portal profile config

  attr_accessor :start_time
  attr_accessor :end_time
  
  attr_accessor :instrument_ids
  attr_accessor :include_test_data
  attr_accessor :site_fields
  attr_accessor :instrument_fields
  attr_accessor :var_fields
  attr_accessor :create_separate_instrument_files
  attr_accessor :create_single_master_file

  attr_accessor :instruments


  def initialize(*args)
    @random_job_id  = SecureRandom.hex(10)
    @creation_time  = Time.now
    @profile        = Profile.first


    @start_time                       = Time.parse(args[0])
    @end_time                         = Time.parse(args[1])

    @instrument_ids                   = args[2]
    @include_test_data                = args[3]
    @site_fields                      = args[4]
    @instrument_fields                = args[5]
    @var_fields                       = args[6]
    @create_separate_instrument_files = args[7]

    @create_single_master_file = ! create_separate_instrument_files


    @instruments = Instrument.where(id: self.instrument_ids) 

    # Make sure the tmp dir exists
    require 'fileutils'
    FileUtils.mkpath(BulkDownload.processing_dir)

  end

  def creation_time_string
    self.creation_time.strftime('%Y-%m-%d_%H-%M-%S')
  end


  def profile_string
    self.profile.project.parameterize
  end





  def final_file_name_base    
    return "#{self.profile_string}_#{self.creation_time_string}"
  end


  def final_gz_file_path
    return "#{BulkDownload.tmp_dir}/#{self.final_file_name_base}.csv.gz" 
  end

  def final_tar_file_path
    return "#{BulkDownload.tmp_dir}/#{self.final_file_name_base}.tar.gz" 
  end


  def placeholder_file_path
    return "#{BulkDownload.tmp_dir}/#{self.final_file_name_base}.temp"
  end

  def var_temp_output_file_path(var)
    var_output_file_name = "#{self.random_job_id}_instrument_#{var.instrument_id}_var_#{var.id}.csv"
    
    var_output_file_path = "#{BulkDownload.processing_dir}/#{var_output_file_name}"

    return var_output_file_path
  end
        
        





  def instrument_zip_file_path(instrument)
    site_string           = instrument.site.name.parameterize
    instrument_string     = instrument.name.parameterize
    instrument_id_string  = "inst-id-#{instrument.id}"

    file_name = "#{self.profile_string}_#{site_string}_#{instrument_string}_#{instrument_id_string}_#{self.creation_time_string}"
    file_path = "#{BulkDownload.processing_dir}/#{file_name}.csv.gz" 

    return file_path
  end



  def instrument_csv_header(instrument)

    # Get the header rows for the master csv file
    csv_header_rows =  "# CSV file creation initiated at: #{self.creation_time.to_s}\n"
    csv_header_rows += "# Start Date (inclusive): #{self.start_time.strftime('%Y-%m-%d')}\n"
    csv_header_rows += "# End Date (inclusive):   #{self.end_time.strftime('%Y-%m-%d')}\n"
    csv_header_rows += "# Include Test Data: #{self.include_test_data}\n"
    csv_header_rows += "# Instrument ID: #{instrument.id}\n"
    csv_header_rows += "# Instrument Names: #{instrument.name}\n"

    csv_header_rows += self.row_labels
  end


  def instrument_header_row_file_path(instrument)
    header_row_file_name = "#{self.random_job_id}_instrument_#{instrument.id}_header_row.csv"

    return "#{BulkDownload.processing_dir}/#{header_row_file_name}"
  end  

  def instrument_header_row_zip_file_path(instrument)
    header_row_file_name = "#{self.random_job_id}_instrument_#{instrument.id}_header_row.csv.gz"

    return "#{BulkDownload.processing_dir}/#{header_row_file_name}"
  end  


  def create_instrument_csv_header_zip_file(instrument)


    # write the header rows to it's own file
    File.write(self.instrument_header_row_file_path(instrument), self.instrument_csv_header(instrument) )

    # zip the temp file
    command = "gzip -f #{self.instrument_header_row_file_path(instrument)}"
    system(command)

    return self.instrument_header_row_zip_file_path(instrument)
  end



  def master_csv_header
    # Get the header rows for the master csv file
    csv_header_rows =  "# CSV file creation initiated at: #{self.creation_time.to_s}\n"
    csv_header_rows += "# Start Date (inclusive): #{self.start_time.strftime('%Y-%m-%d')}\n"
    csv_header_rows += "# End Date (inclusive):   #{self.end_time.strftime('%Y-%m-%d')}\n"
    csv_header_rows += "# Include Test Data: #{self.include_test_data}\n"
    csv_header_rows += "# Instrument IDs: #{self.instrument_ids.join(', ')}\n"
    csv_header_rows += "# Instrument Names: #{self.instruments.pluck(:name).join(', ')}\n"

    csv_header_rows += self.row_labels
  end


  def header_row_file_path
    header_row_file_name = "#{self.random_job_id}_header_row.csv"

    return "#{BulkDownload.processing_dir}/#{header_row_file_name}"
  end


  def header_row_zip_file_path
    return "#{self.header_row_file_path}.gz"
  end  


  def create_master_csv_header_zip_file

    # write the header rows to it's own file
    File.write(self.header_row_file_path, self.master_csv_header)

    # zip the temp file
    command = "gzip -f #{self.header_row_file_path}"
    system(command)

    return self.header_row_zip_file_path
  end



  def row_labels
    row_labels = Array.new

    row_labels.push('measurement_time')
    row_labels.push('measurement_value')
    row_labels.push('is_test_value')

    prefix = 'site'
    self.site_fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'instrument'
    self.instrument_fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    prefix = 'var'
    self.var_fields.each do |field|
      label = ["#{prefix}_#{field}".parameterize.underscore]
      row_labels.push(label.to_csv.to_s.chomp.dump)
    end

    row_label = row_labels.join(',') + "\n"
    
    return row_label
  end







  def self.default_site_fields
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


def self.default_instrument_fields
    instrument_fields = {
      'id'                  => true,
      'name'                => true,
      'sensor_id'           => true,
      'description'         => false,
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


  def self.default_var_fields
    var_fields = {
      'name'                      => true,
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


  def self.tmp_dir
    return "/tmp/bulk_downloads"
  end


  def self.processing_dir
    return "#{BulkDownload.tmp_dir}/processing"
  end

  def self.bulk_data_bytes_used
    # Total size of all bulk data packages (Includes temporary files):
    size_in_bytes = Dir["#{BulkDownload.tmp_dir}/**/*"].select { |f| File.file?(f) }.sum { |f| File.size(f) }
  end



end
