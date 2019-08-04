class DropMeasurementsTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :measurements
  end
end
