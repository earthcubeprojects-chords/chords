class AddVarsAssociationToUnit < ActiveRecord::Migration[5.1]
  def change
  	add_column :vars, :unit_id, :integer, :default => 1
    add_index 'vars', ['unit_id'], :name => 'index_vars_on_unit_id'
  end
end
