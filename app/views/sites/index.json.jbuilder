json.array!(@sites) do |site|
  json.extract! site, :id, :name, :lat, :lon
  json.url site_url(site, format: :json)
end
