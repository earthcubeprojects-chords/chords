namespace :db do
  desc "refresh measurement counts"
  task :refresh_measurement_counts => :environment do |task, args|
    if defined? TsPoint
      puts 'Refreshing Measurement Counts:'

      Instrument.all.each do |instrument|
        begin
          puts "Refreshing counts for instrument: #{instrument.id}"

          count = GetTsCount.call(TsPoint, "value", instrument.id, :not_test)
          test_count = GetTsCount.call(TsPoint, "value", instrument.id, :test)

          puts "\tmeasurements: #{count}\ttest_measurements: #{test_count}"

          instrument.update_attributes!(measurement_count: count, measurement_test_count: test_count)
        rescue Exception, e
          puts "Problem refreshing counts for instrument: #{instrument.id}"
          next
        end
      end
    end
  end
end
