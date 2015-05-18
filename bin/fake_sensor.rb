#!/usr/bin/env ruby

require 'net/http'

# get 'measurements/url_create/:instrument_id/:parameter/:value/:unit' => 'measurements#url_create'



if (ARGV.count != 6)
  put "./fake_sensor URL INSTRUMENT_ID PARAMETER VALUE UNIT FREQUENCY"
  exit
end
# puts ARGV

hostname = ARGV[0]
instrument_id = ARGV[1]
parameter = ARGV[2]
value = ARGV[3]
unit = ARGV[4]

frequency = ARGV[5].to_i

current_value = value.to_f

while 1 do  
  rand = Random.rand(5.0) / 100 

  temp_diff = rand - 0.025
  current_value = current_value + temp_diff
# puts "#{rand} #{temp_diff} #{current_temp}"
# puts temp_diff 
encoded = URI::encode(current_value.to_s)
  # url = URI.parse("http://52.11.141.168:3000/measurements/url_create/1?parameter=temperature&value=#{encoded}&unit=C")
  url = URI.parse("http://#{hostname}/measurements/url_create/#{instrument_id}?parameter=#{current_value}&value=#{value}&unit=#{unit}")
  puts url
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }
#   # puts res.body
  sleep(frequency)
end

