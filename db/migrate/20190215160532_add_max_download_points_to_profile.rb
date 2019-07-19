class AddMaxDownloadPointsToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :max_download_points, :integer
    remove_column :profiles, :google_maps_key
  end
end
