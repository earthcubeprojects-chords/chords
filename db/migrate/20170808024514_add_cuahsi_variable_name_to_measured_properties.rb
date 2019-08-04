class AddCuahsiVariableNameToMeasuredProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :measured_properties, :source, :string, default: 'SensorML'
  end
end
