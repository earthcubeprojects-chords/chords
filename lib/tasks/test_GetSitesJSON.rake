namespace :db do
  desc "test getSitesJson"
  task :test_GetSitesJSON=> :environment do |task, args|

    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/GetSitesJSON"
    uri = URI.parse(uri_path)

    request = Net::HTTP::Post.new uri.path

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
    puts response.body
  end
end
