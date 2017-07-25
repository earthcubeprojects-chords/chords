
namespace :archive do
  task send_data: :environment do |task, args|
    Rails.logger.debug "send data called at " + Time.now.to_s
  end
end
