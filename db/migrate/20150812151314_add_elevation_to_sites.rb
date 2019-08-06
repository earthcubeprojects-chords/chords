class AddElevationToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :elevation, :float, :default => 0.0
  end
end
