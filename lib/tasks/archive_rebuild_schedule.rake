
namespace :archive do
  task rebuild_schedule: :environment do |task, args|

    archive = Archive.first
    
    archive.rebuild_crontab_schedule

  end
end



