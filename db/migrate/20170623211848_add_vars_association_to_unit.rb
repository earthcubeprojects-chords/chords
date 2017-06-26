class AddVarsAssociationToUnit < ActiveRecord::Migration
  def change
  	add_column :vars, :unit_id, :integer
    add_index 'vars', ['unit_id'], :name => 'index_unit_id'
  end
end
