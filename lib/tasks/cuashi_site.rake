require 'task_helpers/cuahsi_helper'
include CuahsiHelper

namespace :db do
  desc "test adding site to hydroserver"
  task :cuahsi_site => :environment do |task, args|

  	data = Site.create_cuahsi_site(1)
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sites"
    CuahsiHelper.send_request(uri_path, data)

  end
end
