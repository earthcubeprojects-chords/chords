require 'task_helpers/cuahsi_helper'
include CuahsiHelper

namespace :db do
  desc "test adding method to hydroserver"
  task :cuahsi_method => :environment do |task, args|

  	Instrument.find_each do |instrument|
	  	data = instrument.create_cuahsi_method
	  	if instrument.get_cuahsi_methodid(data["MethodLink"]) == nil
		    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/methods"
		    CuahsiHelper::send_request(uri_path, data)
		  end
	  end

  end
end
