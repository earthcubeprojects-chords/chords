require 'task_helpers/cuahsi_helper'

namespace :db do
  desc "test adding source to hydroserver"
  task :cuahsi_source => :environment do |task, args|

  	Profile.all.each do |profile|
	  	data = profile.create_cuahsi_source
	  	puts profile.get_cuahsi_sourceid(data["link"])
	  	if profile.get_cuahsi_sourceid(data["link"]) == nil
		    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sources"
		    CuahsiHelper::send_request(uri_path, data)
		    puts response.body
		  end
    end
  end
end
