require 'task_helpers/cuahsi_helper'

namespace :db do
  desc "test adding site to hydroserver"
  task :cuahsi_site => :environment do |task, args|

    Site.find_each do |site|    
    	data = Site.create_cuahsi_site(site.id)
    	if Site.check_duplicate(data["SiteName"]) == nil
	      uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sites"
	      CuahsiHelper::send_request(uri_path, data)
	    end
    end

  end
end
