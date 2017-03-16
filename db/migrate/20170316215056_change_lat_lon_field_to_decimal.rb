class ChangeLatLonFieldToDecimal < ActiveRecord::Migration

  def change
    change_column :sites, :lat, :decimal, :precision => 15, :scale => 13
    change_column :sites, :lon, :decimal, :precision => 15, :scale => 13
    change_column :sites, :elevation, :decimal, :precision => 15, :scale => 13
  end
end
