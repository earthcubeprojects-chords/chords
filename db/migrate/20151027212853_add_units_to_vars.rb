class AddUnitsToVars < ActiveRecord::Migration
  def change
    add_column :vars, :units, :string,  null: false, :default => 'C'
    add_reference  :vars, :measured_property, index: true,null: false, :default => 795
  end

end

