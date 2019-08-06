class AddCuahsiSiteCodeToSites < ActiveRecord::Migration[5.1]
  def change
    add_column :sites, :cuahsi_site_code, :integer
  end
end
