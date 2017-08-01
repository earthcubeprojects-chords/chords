require 'task_helpers/cuahsi_helper'

namespace :db do
  desc "test adding site to hydroserver"
  task :cuahsi_site => :environment do |task, args|

    Site.find_each do |site|    
    	data = site.create_cuahsi_site
    	if site.find_site == nil
	      uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sites"
	      response = CuahsiHelper::send_request(uri_path, data)
        site.find_site
	    end
    end

  end
end
