class AddCuahsiSiteCodeToSites < ActiveRecord::Migration
  def change
    add_column :sites, :cuahsi_site_code, :integer
  end
end
