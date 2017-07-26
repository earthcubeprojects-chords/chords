require 'task_helpers/cuahsi_helper'
include CuahsiHelper

namespace :db do
  desc "test adding method to hydroserver"
  task :cuahsi_method => :environment do |task, args|

  	data = Instrument.create_cuahsi_method(1)
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/methods"

    CuahsiHelper.send_request(uri_path, data)

  end
end
