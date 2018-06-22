require 'json'
class MakeGeoJsonFromTsPoints
  # Convert an array of TsPoint to JSON
  def self.call(ts_points, metadata, profile, instrument)
    vars_by_id = {}
    Var.where(instrument: instrument).each{ |v| vars_by_id[v[:id]] = v }

    source = {}
    source[:type] = 'FeatureCollection'
    source[:features] = []
    source[:features][0] = {}

    feature = source[:features][0]

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
    feature[:properties][:measurements_in_file] = 0
    feature[:properties][:data] = []

    data = {}

    # aggregate tspoints by timestamp
    ts_points.each do |point|
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
      feature[:properties][:data] << data[key]
      feature[:properties][:measurements_in_file] += 1
    end

    return source.to_json
  end
end
