json.array!(@measured_properties) do |measured_property|
  json.extract! measured_property, :id, :name, :label, :url, :definition
  json.url measured_property_url(measured_property, format: :json)
end
