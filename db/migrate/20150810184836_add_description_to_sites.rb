class AddDescriptionToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :description, :text
  end
end
