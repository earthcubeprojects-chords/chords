namespace :db do
  desc "test adding variable to hydroserver"
  task :cuahsi_test_variable => :environment do |task, args|

  	data = Var.create_cuahsi_variable(3)
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/variables"

    CuahsiHelper.send_request(uri_path, data)
  end
end
