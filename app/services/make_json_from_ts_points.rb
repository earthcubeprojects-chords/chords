require 'json'
class MakeJsonFromTsPoints
  # Convert an array of TsPoint to JSON
  def self.call(ts_points, metadata)
    source = metadata
    source["Data"] = ts_points.to_a
    json_points = source.to_json
    return json_points
  end
end