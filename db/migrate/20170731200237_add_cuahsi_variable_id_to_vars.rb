class AddCuahsiVariableIdToVars < ActiveRecord::Migration[5.1]
  def change
    add_column :vars, :cuahsi_variable_id, :integer
  end
end
