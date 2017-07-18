namespace :db do
  desc "test adding source to hydroserver"
  task :cuahsi_test => :environment do |task, args|
  	username = 'chords'
  	password = 'chords'
  	sourceID = 1
  	sourceName = 'name'

  	data = {
	    "username" => username,
	    "password" => password,
	    "organization" =>"CHORDS",
	    "description" => "desc",
	    "link" => "http://example.com",
	    "name" => "name",
	    "phone" =>"012-345-6789",
	    "email" =>"test@gmail.com",
	    "address" => sourceName,
	    "city" => sourceName,
	    "state" => "California",
	    "zipcode" => "098762",
	    "citation" => "uploaded from python as a test",
	    "metadata" => 1
		}

    uri = URI.parse("http://hydroportal.cuahsi.org/CHORDS/index.php/default/services/api/sources")

    request = Net::HTTP::Post.new uri.path
    request.body = data.to_json
    # request['Content-Type'] = 'application/json'
    
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      # http.ssl_version = :SSLv3
      response = http.request request

      puts response.inspect
      puts response.body
    end
    
    
  end
end
