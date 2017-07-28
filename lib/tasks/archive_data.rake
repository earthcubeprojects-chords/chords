
namespace :archive do
  task send_data: :environment do |task, args|
    Rails.logger.debug "send data called at " + Time.now.utc.to_s
    
    # retrieve the current archive jobs data points to be sent
    jobs = ArchiveJob.where("status = 'scheduled'")

    profile = Profile.first
    sourceID = Profile.get_cuahsi_sourceid(profile.domain_name)

    # loops through the jobs
    jobs.each do |job|

      # retrieve the data points for the date range
      Instrument.all.each do |inst|
        points = GetTsPoints.call(TsPoint, "data", inst.id, job.start_at, job.end_at)
      

        # extract site, instrument and var information
        siteID = Site.get_cuahsi_siteid(inst.site.name) 
        url = Instrument.instrument_url(inst.id)
        methodID = Instrument.get_cuahsi_methodid(url)

        points.each do |p|
          variableID = Var.get_cuahsi_variableid(p["var"])

          # build the data array
          data = Array.new
          data.push(p["time"])
          data.push(p["value"])
      

          # send the data array
          Measurement.create_cuahsi_value(data, sourceID, siteID, methodID, variableID)
        end
      end
      
      # retrieve any errors that occurred
      
      # update status of the archive job
      job.status = 'complete'
      job.save
    end
  end
end
