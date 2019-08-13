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

# /measurements/url_create?instrument_id=1&temp=100.4&pressure=110.1&at=2019-08-13T07:17:13.170Z&email=admin@chordsrt.com&api_key=[INSERT_API_KEY]&test

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
                  "measured_at": "2019-08-13T07:17:13.170Z",
                  "value": 2.2323
               },
               {
                  "variable": "pressure",
                  "measured_at": "2019-08-13T07:17:13.170Z",
                  "value": 110.1
               },
               {
                  "variable": "temp",
                  "measured_at": "2019-08-13T07:17:14.170Z",
                  "value": 3.2323
               },
               {
                  "variable": "pressure",
                  "measured_at": "2019-08-13T07:17:14.170Z",
                  "value": 111.1
               },
               {
                  "variable": "temp",
                  "measured_at": "2019-08-13T07:17:15.170Z",
                  "value": 4.2323
               },
               {
                  "variable": "pressure",
                  "measured_at": "2019-08-13T07:17:15.170Z",
                  "value": 112.3
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
