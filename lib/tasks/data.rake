#task default: %w[hello]
require 'net/http'

namespace :data do
  task :seed, [:amount] => :environment do |task, args|
  	uri = URI('http://localhost/measurements/url_create?')

  	#Net::HTTP.start(uri.host, uri.port) do |http|
  	#request = Net::HTTP::Get.new uri

  	#response = http.request request # Net::HTTPResponse object
  	puts(uri)
  	#puts "Your amount is #{args.amount}"
  	instrument_id = 1
	instrument = Instrument.find(instrument_id)
  	Instrument.find(params[:instrument_id]).vars.each do |var|
        measured_at_parameters.push(var.measured_at_parameter)
        variable_shortnames.push(var.shortname)
    end
  end
  task :work, [:option, :foo, :bar] => [:environment] do |t, args|
    puts "work", args
  end
end

   
        # see if the parameter
# TYPE IN POWER SHELL rake data:seed[100]
#http://davidlesches.com/blog/passing-arguments-to-a-rails-rake-task
#http://stackoverflow.com/questions/825748/how-to-pass-command-line-arguments-to-a-rake-task
################################################################################################################################################################################
#http://stackoverflow.com/questions/825748/how-to-pass-command-line-arguments-to-a-rake-task


#$i= 0

#task :data => :environment  do
#	uri = URI('http://localhost/measurements/url_create?')

#	Net::HTTP.start(uri.host, uri.port) do |http|
 # 	request = Net::HTTP::Get.new uri

  #	response = http.request request # Net::HTTPResponse object
  #	puts (response)
  #	puts (http)
	#end


# https://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html

###################################################################################################################################################################################

	##while $i < 500 do
		##y = Random.new
		##x = y.rand(1...200)

		##instrument_id = 1
		##instrument = Instrument.find(instrument_id)
		##puts instrument.to_s
		#puts "This is a data point: #{$i} " 




		#work thermometer
		##work = URI("http://localhost/measurements/url_create?instrument_id=1&temp=#{x}&shortname=109.9&key=key&test")
		#Windy
		##uri = URI("http://localhost/measurements/url_create?instrument_id=2&wspd=#{x}.4&wdir=208.7&key=key&test")
		#Windy Clone
		##wclone = URI("http://localhost/measurements/url_create?instrument_id=3&wspd=#{x}&wdir=311.5&key=key&test")

		##Net::HTTP.get(work)
		##Net::HTTP.get(uri)
		##Net::HTTP.get(wclone)
		##$i += 1
	##end
