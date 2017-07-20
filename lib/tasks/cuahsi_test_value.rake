namespace :db do
  desc "test adding value to hydroserver"
  task :cuahsi_test_value => :environment do |task, args|

  	data = Measurement.create_cuahsi_value(1, 1, 1, 1, 1)
    puts data

    uri = URI.parse("http://hydroportal.cuahsi.org/CHORDS/index.php/default/services/api/values")

    request = Net::HTTP::Post.new uri.path
    request.body = data.to_json
    request['Content-Type'] = 'application/json'

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
    puts response.inspect
  end
end
