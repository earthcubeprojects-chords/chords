class DropMeasurementsTable < ActiveRecord::Migration
  def change
    drop_table :measurements
  end
end
