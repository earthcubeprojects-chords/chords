require 'json'
class MakeGeoJsonFromTsPoints
  # Convert an array of TsPoint to JSON
  def self.call(ts_points, metadata, profile, instrument)

    vars_by_id = {}
    Var.all.where("instrument_id = #{instrument.id}").each {|v| vars_by_id[v[:id]] = v}


    source = metadata
    source = Hash.new
    source['type'] = "FeatureCollection"
    source['features'] = Array.new
    source['features'][0] = Hash.new 
    source['features'][0]['type'] = "Feature"
    source['features'][0]['geometry'] = Hash.new 

    source['features'][0]['geometry']['type'] = "Point"
    source['features'][0]['geometry']['coordinates'] = [instrument.site.lon, instrument.site.lat, instrument.site.elevation];
    source['features'][0]['properties'] = Hash.new 

    source['features'][0]['properties']['project'] = profile.project
    source['features'][0]['properties']['affiliation'] = profile.affiliation
    source['features'][0]['properties']['site'] = instrument.site.name
    source['features'][0]['properties']['site_id'] = instrument.site.id
    source['features'][0]['properties']['instrument'] = instrument.name
    source['features'][0]['properties']['instrument_id'] = instrument.id

    data  = Array.new
    ts_points.each do |point|
      # data_point = Hash.new
      # data_point['time'] = point['time']
      # point['variable_name'] = point['var']
      var_id = point['var'].to_i
      point['variable_name'] = vars_by_id[var_id].name.to_s
      point['variable_shortname'] = vars_by_id[var_id].shortname.to_s
      point['units'] = vars_by_id[var_id].units.to_s

      point.delete('var')
      point.delete('inst')
      point.delete('site')

      data << point
    end
    

    source['features'][0]['properties']['measurements_in_file'] = ts_points.count
      
    source["Data"] = data
    json_points = source.to_json
    return json_points
  end
end