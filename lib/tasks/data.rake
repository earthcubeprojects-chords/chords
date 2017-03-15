#task default: %w[hello]
require 'net/http'


$i= 0

task :data => :environment  do
	while $i < 500 do
		y = Random.new
		x = y.rand(1...200)

		instrument_id = 1
		instrument = Instrument.find(instrument_id)
		puts instrument.to_s
		#puts "This is a data point: #{$i} " 
		#work thermometer
		work = URI("http://localhost/measurements/url_create?instrument_id=1&temp=#{x}&shortname=109.9&key=key&test")
		#Windy
		uri = URI("http://localhost/measurements/url_create?instrument_id=2&wspd=#{x}.4&wdir=208.7&key=key&test")
		#Windy Clone
		wclone = URI("http://localhost/measurements/url_create?instrument_id=3&wspd=#{x}&wdir=311.5&key=key&test")

		Net::HTTP.get(work)
		Net::HTTP.get(uri)
		Net::HTTP.get(wclone)
		$i += 1
	end
end