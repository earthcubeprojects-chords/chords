require 'task_helpers/cuahsi_helper'
include CuahsiHelper

namespace :db do
  desc "test adding variable to hydroserver"
  task :cuahsi_variable => :environment do |task, args|

    Var.all.each do |var|
    	data = var.create_cuahsi_variable
    	if var.get_cuahsi_variableid(data["VariableCode"]) == nil
	      uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/variables"
	      CuahsiHelper::send_request(uri_path, data)
        var.get_cuahsi_variableid(data["VariableCode"])
	    end
    end
  end
end
