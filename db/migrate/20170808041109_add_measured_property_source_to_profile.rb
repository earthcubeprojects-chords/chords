class AddMeasuredPropertySourceToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :measured_property_source, :string, default: 'SensorML'
  end
end
