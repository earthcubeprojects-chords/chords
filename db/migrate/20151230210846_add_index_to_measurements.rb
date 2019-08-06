class AddIndexToMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_index :measurements, :measured_at
  end
end
