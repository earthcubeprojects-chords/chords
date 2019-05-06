require 'json'
class MakeGeoJsonFromTsPoints
  def self.call(ts_points, profile, instruments)
    if instruments.is_a?(Instrument)
      instruments = [instruments]
    end

    if !(instruments.is_a?(Array) || instruments.is_a?(ActiveRecord::Relation))
      raise ArgumentError.new('instruments parameter must be an Instrument object or an array of Instrument objects')
    end

    vars_by_inst = {}

    Var.where(instrument: instruments).each do |v|
      vars_by_inst[v[:instrument_id]] = {} if !vars_by_inst[v[:instrument_id]]
      vars_by_inst[v[:instrument_id]][v[:id]] = v
    end

    source = {}
    source[:type] = 'FeatureCollection'
    source[:features] = []

    instruments.each do |inst|
      feature = MakeGeoJsonFromTsPoints.make_feature(inst, profile)

      ts_data = MakeGeoJsonFromTsPoints.select_inst_from_ts_points(ts_points, inst.id)
      feature[:properties] = feature[:properties].merge(MakeGeoJsonFromTsPoints.make_properties(ts_data, vars_by_inst[inst.id]))

      source[:features] << feature
    end

    return source.to_json
  end

  def self.make_feature(instrument, profile)
    chords_version = begin
                       ENV.fetch('DOCKER_TAG')
                     rescue Exception => e
                       'unknown'
                     end

    chords_revision = begin
                        ENV.fetch('CHORDS_GIT_SHA')[0..6]
                      rescue Exception => e
                        'unknown'
                      end

    feature = {}
    feature[:type] = 'Feature'
    feature[:geometry] = {}
    feature[:geometry][:type] = 'Point'
    feature[:geometry][:coordinates] = [instrument.site.lon.to_f, instrument.site.lat.to_f, instrument.site.elevation.to_f]

    feature[:properties] = {}
    feature[:properties][:project] = profile.project
    feature[:properties][:affiliation] = profile.affiliation
    feature[:properties][:doi] = "https://doi.org/#{profile.doi}" if profile.doi
    feature[:properties][:doi_citation] = "https://citation.crosscite.org/?doi=#{profile.doi}" if profile.doi
    feature[:properties][:chords_version] = chords_version
    feature[:properties][:chords_version_sha] = chords_revision
    feature[:properties][:site] = instrument.site.name
    feature[:properties][:site_id] = instrument.site.id
    feature[:properties][:instrument] = instrument.name
    feature[:properties][:instrument_id] = instrument.id
    feature[:properties][:sensor_id] = instrument.sensor_id
    feature[:properties][:variables] = MakeGeoJsonFromTsPoints.make_vars(instrument)

    return feature
  end

  def self.make_vars(instrument)
    data = []
    vars = instrument.vars

    vars.each do |var|
      temp = {}
      temp[:name] = var.try(:name).to_s
      temp[:shortname] = var.try(:shortname).to_s
      temp[:measured_property] = var.try(:measured_property).try(:label)
      temp[:measured_property_definition] = var.try(:measured_property).try(:definition)
      temp[:measured_property_source] = var.try(:measured_property).try(:source)
      temp[:measured_property_url] = var.try(:measured_property).try(:url)
      temp[:units_name] = var.try(:unit).try(:name)
      temp[:units_abbreviation] = var.try(:unit).try(:abbreviation)
      temp[:units_type] = var.try(:unit).try(:unit_type)
      temp[:units_source] = var.try(:unit).try(:source)

      data << temp
    end

    data
  end

  def self.make_properties(ts_data, vars_by_id)
    data = {}
    properties = {}
    properties[:data] = []
    properties[:timestamps_in_feature] = 0
    properties[:measurements_in_feature] = 0

    # aggregate tspoints by timestamp
    ts_data.each do |point|
      var_id = point['var'].to_i
      timestamp = point['time']

      data[timestamp] = {time: timestamp, test: point['test'], measurements: {}} unless data.key?(timestamp)

      shortname = vars_by_id[var_id].try(:shortname).to_s
      data[timestamp][:measurements][shortname] = point['value']

      properties[:measurements_in_feature] += 1
    end

    # put aggregated points into data array
    data.keys.sort.each do |key|
      properties[:data] << data[key]
      properties[:timestamps_in_feature] += 1
    end

    return properties
  end

  def self.select_inst_from_ts_points(ts_points, inst_id)
    ts_points.select{|ts| ts['inst'] == inst_id.to_s}
  end
end
