namespace :db do
  desc "test getSitesJson"
  task :test_GetSitesJSON=> :environment do |task, args|

    uri = URI.parse("http://hydroportal.cuahsi.org/CHORDS/index.php/default/services/api/GetSitesJSON")

    request = Net::HTTP::Post.new uri.path

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
    puts response.body
  end
end
