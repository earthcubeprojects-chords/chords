class AddMeasurementCountToInstruments < ActiveRecord::Migration[5.1]
  def up
    add_column :instruments, :measurement_count, :integer, null: false, default: 0
    add_column :instruments, :measurement_test_count, :integer, null: false, default: 0

    change_column :instruments, :measurement_count, :bigint
    change_column :instruments, :measurement_test_count, :bigint

    if defined? TsPoint
      puts 'Populating Measurement Counts:'

      Instrument.all.each do |instrument|
        begin
          puts "Populating counts for instrument: #{instrument.id}"

          count = GetTsCount.call(TsPoint, "value", instrument.id, :not_test)
          test_count = GetTsCount.call(TsPoint, "value", instrument.id, :test)

          instrument.update_attributes!(measurement_count: count, measurement_test_count: test_count)
        rescue Exception, e
          next
        end
      end
    end
  end

  def down
    remove_column :instruments, :measurement_count
    remove_column :instruments, :measurement_test_count
  end
end
