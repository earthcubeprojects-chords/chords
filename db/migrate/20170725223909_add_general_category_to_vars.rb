class AddGeneralCategoryToVars < ActiveRecord::Migration
  def change
    add_column :vars, :general_category, :string
  end
end
