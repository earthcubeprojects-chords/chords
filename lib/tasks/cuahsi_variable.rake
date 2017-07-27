require 'task_helpers/cuahsi_helper'

namespace :db do
  desc "test adding variable to hydroserver"
  task :cuahsi_variable => :environment do |task, args|

    Var.find_each do |var|
    	if Var.check_duplicate(var.id) == nil
    		data = Var.create_cuahsi_variable(var.id)
	      uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/variables"
	      CuahsiHelper::send_request(uri_path, data)
	    end
    end
  end
end
