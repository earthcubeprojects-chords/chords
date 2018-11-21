class AddArchiveUrlToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :data_archive_url, :string
  end
end
