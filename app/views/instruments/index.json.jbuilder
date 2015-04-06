json.array!(@instruments) do |instrument|
  json.extract! instrument, :id, :name, :site_id
  json.url instrument_url(instrument, format: :json)
end
