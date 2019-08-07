class AddIndexToMeasurements < ActiveRecord::Migration
  def change
    add_index :measurements, :measured_at
  end
end
