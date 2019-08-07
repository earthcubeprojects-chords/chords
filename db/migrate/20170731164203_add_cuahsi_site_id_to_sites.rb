class AddCuahsiSiteIdToSites < ActiveRecord::Migration
  def change
    add_column :sites, :cuahsi_site_id, :integer
  end
end
