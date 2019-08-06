class AddCuahsiSourceIdToProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :cuahsi_source_id, :integer
  end
end
