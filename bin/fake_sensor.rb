#!/usr/bin/env ruby

require 'net/http'

# get 'measurements/url_create/:instrument_id/:parameter/:value/:unit' => 'measurements#url_create'

current_temp = 15
while 1 do  
  rand = Random.rand(5.0) / 100 

  temp_diff = rand - 0.025
  current_temp = current_temp + temp_diff
# puts "#{rand} #{temp_diff} #{current_temp}"
# puts temp_diff 
encoded = URI::encode(current_temp.to_s)
  url = URI.parse("http://localhost:3000/measurements/url_create/1?parameter=temperature&value=#{encoded}&unit=C")
  # puts url
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
#   # puts res.body
  sleep(1)
end

