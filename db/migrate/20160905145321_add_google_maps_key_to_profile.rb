class AddGoogleMapsKeyToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :google_maps_key, :string, :length => 255, :default => "none"
  end
end
