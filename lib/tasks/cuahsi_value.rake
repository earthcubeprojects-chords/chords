require 'task_helpers/cuahsi_helper'

namespace :db do
  desc "test adding value to hydroserver"
  task :cuahsi_value => :environment do |task, args|

  	data = Measurement.create_cuahsi_value(1, 1, 1, 1, 1)
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/values"

    send_request(uri_path, data)
  end
end
