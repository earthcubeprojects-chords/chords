class AddDefaultValueToGeneralCategory < ActiveRecord::Migration[5.1]
  def change
  	change_column_default :vars, :general_category, "9"
  end
end
