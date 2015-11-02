class AddUnitsToVars < ActiveRecord::Migration
  def change
    add_column :vars, :units, :string
    add_reference  :vars, :measured_property, index: true
  end

end

