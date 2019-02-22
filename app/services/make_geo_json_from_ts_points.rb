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
    feature = {}
    feature[:type] = 'Feature'
    feature[:geometry] = {}
    feature[:geometry][:type] = 'Point'
    feature[:geometry][:coordinates] = [instrument.site.lon, instrument.site.lat, instrument.site.elevation]

    feature[:properties] = {}
    feature[:properties][:project] = profile.project
    feature[:properties][:affiliation] = profile.affiliation
    feature[:properties][:site] = instrument.site.name
    feature[:properties][:site_id] = instrument.site.id
    feature[:properties][:instrument] = instrument.name
    feature[:properties][:instrument_id] = instrument.id

    return feature
  end

  def self.make_properties(ts_data, vars_by_id)
    data = {}
    properties = {}
    properties[:data] = []
    properties[:measurements_in_feature] = 0

    # aggregate tspoints by timestamp
    ts_data.each do |point|
      var_id = point['var'].to_i
      timestamp = point['time']

      temp = {}
      temp[:variable_name] = vars_by_id[var_id].try(:name).to_s
      temp[:variable_shortname] = vars_by_id[var_id].try(:shortname).to_s
      temp[:units] = vars_by_id[var_id].try(:units).to_s
      temp[:value] = point['value']

      data[timestamp] = {time: timestamp, test: point['test'], vars: []} unless data.key?(timestamp)
      data[timestamp][:vars] << temp
    end

    # put aggregated points into data array
    data.keys.sort.each do |key|
      properties[:data] << data[key]
      properties[:measurements_in_feature] += 1
    end

    return properties
  end

  def self.select_inst_from_ts_points(ts_points, inst_id)
    ts_points.select{|ts| ts['inst'] == inst_id.to_s}
  end
end
