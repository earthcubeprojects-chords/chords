class AddTestToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :test, :boolean, :default => false, :null => false
  end
end
