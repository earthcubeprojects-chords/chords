
namespace :archive do
  task create_jobs: :environment do |task, args|

    archive = Archive.first

    execution_start_time = Time.now.utc

    # puts "creating archive jobs at " + execution_start_time.to_s
    
    
    # get starting time for job creation 
    if archive.last_archived_at != nil
      archive_start_time = archive.last_archived_at
    else 

      #time of first measurement      
      first_point = GetFirstTsPoint.call(TsPoint, 'value')
      
      if(defined? first_point.to_a.first['time'])
        archive_start_time = Time.parse(first_point.to_a.first['time'])
      else
        archive_start_time = "None"
      end    
    end      


    #first time range
    start_at = archive_start_time
    end_at = archive.calculate_end_at(start_at, execution_start_time)    
    
    archive_job_params = Array.new([{:archive_name => archive.name, :start_at => start_at, :end_at => end_at, :status=> 'scheduled'}])

    
    # increment through the time until execution time is reached
    while (end_at < execution_start_time)
      start_at = end_at
      end_at = archive.calculate_end_at(start_at, execution_start_time)    

      archive_job_params.push({:archive_name => archive.name, :start_at => start_at, :end_at => end_at, :status=> 'scheduled'})      
    end
    
    # create the archive jobs
    archive_job_params.each do |params|
      archive_job = ArchiveJob.new(params)
      archive_job.save
    end
      
    # set the last time archive jobs were generated
    archive.last_archived_at = execution_start_time
    archive.save
    
  end
end



