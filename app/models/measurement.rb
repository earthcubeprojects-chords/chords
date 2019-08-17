class Measurement
  # Required dependency for ActiveModel::Errors
  # see https://apidock.com/rails/ActiveModel/Errors
  extend ActiveModel::Naming
  # include ActiveModel::Validations

  attr_reader   :errors

  # Assigned attributes
  attr_accessor :measured_at
  attr_accessor :variable_shortname
  attr_accessor :value
  attr_accessor :is_test_value

  # Calculated attributes
  attr_accessor :timestamp
  attr_accessor :tags

  def initialize(instrument, measurement_json, is_test_value)

    @errors = ActiveModel::Errors.new(self)

    self.variable_shortname = measurement_json['variable']
    self.value = measurement_json['value'].to_f
    self.measured_at = measurement_json['measured_at']
    self.is_test_value = is_test_value


    self.timestamp = begin
                  ConvertIsoToMs.call(self.measured_at)
                rescue ArgumentError, e
                  nil
                end


    # InfluxDB tags
    self.tags = instrument.influxdb_tags_hash
    self.tags[:site] = instrument.site_id
    self.tags[:inst] = instrument.id
    self.tags[:var]  = instrument.get_var_id_by_var_shortname(self.variable_shortname)
    self.tags[:test] = self.is_test_value

  end


  def validate!

    if (self.timestamp.nil?)
      create_err_msg = "Time format error, the timestamp '#{self.measured_at}' violates ISO8601 formatting."
      # errors.add(:timestamp, :blank, message: create_err_msg)
      errors.add(:timestamp, :invalid, message: create_err_msg)
    end

  end


  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end
end