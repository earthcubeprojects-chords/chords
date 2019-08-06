class AddMeasuredPropertySourceToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :measured_property_source, :string, default: 'SensorML'
  end
end
