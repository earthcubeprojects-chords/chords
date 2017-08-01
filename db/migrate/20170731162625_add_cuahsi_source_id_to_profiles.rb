class AddCuahsiSourceIdToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :cuahsi_source_id, :integer
  end
end
