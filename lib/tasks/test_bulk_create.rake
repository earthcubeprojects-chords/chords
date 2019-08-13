desc 'Test the bulk_create POST controller'

require 'net/http'
require 'uri'
require 'json'

# https://gist.github.com/justinwoo/5016513
task bulk_create: :environment do |task, args|

  host = "chords_web"
  url = "http://#{host}/measurements/bulk_create"

  puts "Posting JSON to #{url}"

  email = 'mike@mikedye.com'
  # api_key = 'invlid_key'
  api_key = 'UGg7M3LrVLjhJB_saR2Q'

  payload = 
{
   "email": email,
   "api_key": api_key,
   "data": {
      "instruments": [
         {
            "instrument_id": 1,
            "measurements": [
               {
                  "variable": "temp",
                  "measured_at": "1/1/2019 12:12:12.4324323",
                  "value": 2.2323
               },
               {
                  "variable": "temp",
                  "measured_at": "1/1/2019 12:12:13.4324323",
                  "value": 3.2323
               },
               {
                  "variable": "temp",
                  "measured_at": "1/1/2019 12:12:14.4324323",
                  "value": 4.2323
               }
            ]
         }
      ]
   }
}


  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri)
  request["Accept"] = "application/json"
  request.content_type = "application/json"
  request.body = payload.to_json

  # return http.request(request)
  reponse = http.request(request) 
  puts '*' * 80
  puts reponse.inspect
  puts reponse.code
  puts reponse.body
end
