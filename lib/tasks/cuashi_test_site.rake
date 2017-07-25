namespace :db do
  desc "test adding site to hydroserver"
  task :cuahsi_test_site => :environment do |task, args|

  	data = Site.create_cuahsi_site(3)

    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sites"
    uri = URI.parse(uri_path)

    request = Net::HTTP::Post.new uri.path
    request.body = data.to_json
    request['Content-Type'] = 'application/json'
    
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
  end
end
