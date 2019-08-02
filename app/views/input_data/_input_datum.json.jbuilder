json.extract! input_datum, :id, :name, :origin_lat, :origin_lon, :scanned_at, :header_metadata, :created_at, :updated_at
json.url input_datum_url(input_datum, format: :json)
