class AddGeneralCategoryToVars < ActiveRecord::Migration[5.1]
  def change
    add_column :vars, :general_category, :string
  end
end
