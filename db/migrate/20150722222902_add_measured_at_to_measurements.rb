class AddMeasuredAtToMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :measurements, :measured_at, :datetime
  end
end
