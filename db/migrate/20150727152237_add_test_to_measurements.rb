class AddTestToMeasurements < ActiveRecord::Migration[5.1]
  def change
    add_column :measurements, :test, :boolean, :default => false, :null => false
  end
end
