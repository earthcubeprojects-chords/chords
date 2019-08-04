class ReplaceGeneralCategoryIdWithGeneralCategory < ActiveRecord::Migration[5.1]
  def change
    remove_column :vars, :general_category_id

    add_column :vars, :general_category, :string, :default => 'Unknown'
  end
end
