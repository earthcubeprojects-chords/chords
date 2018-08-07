json.array!(@instruments) do |instrument|
  json.extract! instrument, :id, :sensor_id, :name, :site_id
  json.url instrument_url(instrument, format: :json)
end
