class AddCuahsiVariableNameToMeasuredProperties < ActiveRecord::Migration
  def change
    add_column :measured_properties, :source, :string, default: 'SensorML'
  end
end
