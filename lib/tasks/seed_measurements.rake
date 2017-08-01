namespace :db do
  desc "create random employees"
  current_time = Time.now
  task :seed_measurements, [:points_to_create] => :environment do |task, args|
    instruments = Instrument.all
    instruments.each do |instrument|

      
      # Make a hash out of the set influddb tags
      influxdb_tags = instrument.influxdb_tags_hash

      instrument.vars.each do |variable|
        puts "Creating #{args.points_to_create} timeseries points for variable #{variable.name} on Instrument #{instrument.name}"

        value = variable.random_value(value)
        
        begining_time = current_time - (instrument.sample_rate_seconds * (args.points_to_create.to_i)).seconds
        
          
        # puts "current_time #{current_time}"
        # puts "begining_time #{begining_time}"
        (1..(args.points_to_create.to_i)).each do |point_number|
          value = variable.random_value(value)
          
          measured_at = (begining_time + (instrument.sample_rate_seconds * point_number).seconds).iso8601
          
          tags = influxdb_tags
          tags[:site] = instrument.site.id
          tags[:inst] = instrument.id
          tags[:var]  = variable.id
          tags[:test] = true
          
          timestamp = ConvertIsoToMs.call(measured_at)

          SaveTsPoint.call(timestamp, value, tags)

        end
      end

    end
  end
end