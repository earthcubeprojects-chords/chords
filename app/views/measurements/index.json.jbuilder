json.array!(@measurements) do |measurement|
  json.extract! measurement, :id, :instrument_id, :parameter, :value, :unit
  json.url measurement_url(measurement, format: :json)
end
