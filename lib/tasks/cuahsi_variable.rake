require 'task_helpers/cuahsi_helper'

namespace :db do
  desc "test adding variable to hydroserver"
  task :cuahsi_variable => :environment do |task, args|

    Var.find_each do |var|
    	data = Var.create_cuahsi_variable(var.id)
    	if Var.get_cuahsi_variableid(data["VariableCode"]) == nil
	      uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/variables"

	      send_request(uri_path, data)
	    end
    end
  end
end
