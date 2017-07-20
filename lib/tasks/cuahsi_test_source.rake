namespace :db do
  desc "test adding source to hydroserver"
  task :cuahsi_test_source => :environment do |task, args|

  	data = Profile.create_cuahsi_source

    uri = URI.parse("http://hydroportal.cuahsi.org/CHORDS/index.php/default/services/api/sources")

    request = Net::HTTP::Post.new uri.path
    request.body = data.to_json
    request['Content-Type'] = 'application/json'
    
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
    
  end
end
