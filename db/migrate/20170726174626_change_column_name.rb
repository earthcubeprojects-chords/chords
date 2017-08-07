class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :vars, :general_category, :general_category_id
  end
end
