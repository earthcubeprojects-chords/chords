class AddElevationToSites < ActiveRecord::Migration
  def change
    add_column :sites, :elevation, :float, :default => 0.0
  end
end
