class AddCuahsiVariableIdToVars < ActiveRecord::Migration
  def change
    add_column :vars, :cuahsi_variable_id, :integer
  end
end
