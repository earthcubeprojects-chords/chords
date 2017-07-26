namespace :db do
  desc "test adding method to hydroserver"
  task :cuahsi_test_method => :environment do |task, args|

  	data = Instrument.create_cuahsi_method(2)
    puts data

    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/methods"
    uri = URI.parse(uri_path)

    request = Net::HTTP::Post.new uri.path
    request.body = data.to_json
    request['Content-Type'] = 'application/json'

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
    puts response.inspect

    puts "done"
  end
end
