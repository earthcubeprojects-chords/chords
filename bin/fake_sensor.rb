#!/usr/bin/env ruby

require 'net/http'

# get 'measurements/url_create/:instrument_id/:parameter/:value/:unit' => 'measurements#url_create'



if (ARGV.count != 1)
  # put "./fake_sensor URL INSTRUMENT_ID PARAMETER VALUE UNIT FREQUENCY"
  put "./fake_sensor URL"
  exit
end
# puts ARGV



hostname = ARGV[0]
# instrument_id = ARGV[1]
# parameter = ARGV[2]
# value = ARGV[3]
# unit = ARGV[4]
# 
# frequency = ARGV[5].to_i

frequency = 1

measurement_configurations = Array.new

measurement_configurations.push({:instrument_id => 1, :parameter => 'temperature', :current_value => 15, :unit => 'C'})
measurement_configurations.push({:instrument_id => 2, :parameter => 'velocity', :current_value => 11, :unit => 'mps'})


while 1 do 
  
  measurement_configurations.each do |measurement_configuration|
    # instrument_id = measurement_configuration[:instrument_id]
    # parameter = measurement_configuration[:parameter]
    # current_value = measurement_configuration[:current_value]
    # unit = measurement_configuration[:unit]
    # 

    rand = Random.rand(5.0) / 100 
    temp_diff = rand - 0.025
    measurement_configuration[:current_value] = measurement_configuration[:current_value] + temp_diff

    encoded = URI::encode(measurement_configuration[:current_value].to_s)

    url = URI.parse("http://#{hostname}/measurements/url_create?instrument_id=#{measurement_configuration[:instrument_id]}&parameter=#{measurement_configuration[:parameter]}&value=#{measurement_configuration[:current_value]}&unit=#{measurement_configuration[:unit]}")
    puts url

    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

  end 

#   # puts res.body
  sleep(frequency)
end

