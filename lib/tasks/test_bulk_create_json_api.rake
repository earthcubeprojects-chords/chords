desc 'Test the bulk_create POST controller'

require 'net/http'
require 'uri'
require 'json'

# https://gist.github.com/justinwoo/5016513
task bulk_create_json_api: :environment do |task, args|

  host = "chords_web"
  url = "http://#{host}/measurements/bulk_create"

  puts "Posting JSON to #{url}"


# /measurements/url_create?instrument_id=1&temp=100.4&pressure=110.1&at=2019-08-13T07:17:13.170Z&email=admin@chordsrt.com&api_key=[INSERT_API_KEY]&test

  json_file = "instrument_api_spec.json"
  json_file_path =  "#{Rails.root}/lib/assets/bulk_upload/#{json_file}"
  file_content = File.read(json_file_path)
  payload = JSON.parse(file_content)



  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri)
  request["Accept"] = "application/json"
  request.content_type = "application/vnd.api+json"
  request.body = payload.to_json

  # return http.request(request)
  reponse = http.request(request) 
  puts '*' * 80
  puts reponse.inspect
  puts reponse.code
  puts reponse.body
end



#   payload = 
# {
#    "email": email,
#    "api_key": api_key,
#    "data": {
#       "instruments": [
#          {
#             "instrument_id": 1,
#             "measurements": [
#                {
#                   "variable": "pressure",
#                   "measured_at": "2019-08-13T07:17:15.170Z",
#                   "value": 112.3
#                }
#             ]
#          }
#       ]
#    }
# }
