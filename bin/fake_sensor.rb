#!/usr/bin/env ruby

require 'net/http'

# get 'measurements/url_create/:instrument_id/:parameter/:value/:unit' => 'measurements#url_create'

last_temp = 15
while 1 do 

  temp_diff = Random.rand(0.05) - 0.1
  current_temp = last_temp + temp_diff

# puts temp_diff 
encoded = URI::encode(current_temp.to_s)
  url = URI.parse("http://localhost:3000/measurements/url_create/1?parameter=temperature&value=#{encoded}&unit=C")
  # puts url
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
  # puts res.body
  sleep(1)
end

