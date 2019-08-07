class AddMeasuredAtToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :measured_at, :datetime
  end
end
