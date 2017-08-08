class AddDefaultValueToCuahsiVariableId < ActiveRecord::Migration
  def change
  	change_column_default :vars, :cuahsi_variable_id, 1
  end
end
