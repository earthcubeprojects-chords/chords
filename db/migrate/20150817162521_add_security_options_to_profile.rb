class AddSecurityOptionsToProfile < ActiveRecord::Migration[5.1]
  def change
     add_column :users, :is_administrator, :boolean, :default => false
     add_column :users, :is_data_viewer, :boolean, :default => true
     add_column :users, :is_data_downloader, :boolean, :default => true


     add_column :profiles, :secure_administration, :boolean, :default => false
     add_column :profiles, :secure_data_viewing, :boolean, :default => true
     add_column :profiles, :secure_data_download, :boolean, :default => true
     add_column :profiles, :secure_data_entry, :boolean, :default => true
     add_column :profiles, :data_entry_key, :string, :length => 255
  end
end
