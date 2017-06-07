namespace :db do
  desc "create random employees"
  current_time = Time.now
  task :seed_measurements, [:points_to_create] => :environment do |task, args|
    instruments = Instrument.all
    instruments.each do |instrument|
      instrument.vars.each do |variable|
        puts "Creating #{args.points_to_create} timeseries points for variable #{variable.name} on Instrument #{instrument.name}"

        value = variable.random_value(value)
        
        begining_time = current_time - (instrument.sample_rate_seconds * (args.points_to_create.to_i)).seconds
        # puts "current_time #{current_time}"
        # puts "begining_time #{begining_time}"
        (1..(args.points_to_create.to_i)).each do |point_number|
          value = variable.random_value(value)
          
          measured_at = (begining_time + (instrument.sample_rate_seconds * point_number).seconds).iso8601
          # puts "#{value} at #{measured_at}"

          SaveTsPoint.call(
            TsPoint,
            { 
              timestamp:  ConvertIsoToMs.call(measured_at),
              site:       instrument.site.id, 
              inst:       instrument.id, 
              var:        variable.id,
              test:       true,
              value:      value
            }
          )        


        end
      end

    end
  end
end