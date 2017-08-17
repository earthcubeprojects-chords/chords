class AddSiteTypeToSite < ActiveRecord::Migration
  def change
    add_reference :sites, :site_type, index: true, foreign_key: true
  end
end
