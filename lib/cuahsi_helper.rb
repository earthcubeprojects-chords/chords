module CuahsiHelper

	def send_request(uri_path, data)
    uri = URI.parse(uri_path)

    request = Net::HTTP::Post.new uri.path
    request.body = data.to_json
    request['Content-Type'] = 'application/json'

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => false) do |http|
      response = http.request request
    end
  end
  
end