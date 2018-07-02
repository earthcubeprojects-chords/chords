require 'task_helpers/cuahsi_helper'

namespace :db do
  desc "test adding value to hydroserver"
  task :cuahsi_value => :environment do |task, args|
    data = {
      "user" => Rails.application.config.x.archive['username'],
      "password" => Rails.application.config.x.archive['password'],
      "SiteID" => 1,
      "VariableID" => 1,
      "MethodID" => 1,
      "SourceID" => 1,
      "values" => [1]
    }

    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/values"

    CuahsiHelper::send_request(uri_path, data)
  end
end
