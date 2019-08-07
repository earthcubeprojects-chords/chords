class AddDefaultValueToGeneralCategory < ActiveRecord::Migration
  def change
  	change_column_default :vars, :general_category, "9"
  end
end
