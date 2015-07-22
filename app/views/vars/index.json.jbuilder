json.array!(@vars) do |var|
  json.extract! var, :id, :name, :shortname, :instrument_id
  json.url var_url(var, format: :json)
end
