class RemoveCuahsiArchiveVariables < ActiveRecord::Migration[5.1]
  def change
    remove_column :sites, :cuahsi_site_code, :integer
    remove_column :sites, :cuahsi_site_id, :integer

    remove_column :profiles, :cuahsi_source_id, :integer

    remove_column :instruments, :cuahsi_method_id, :integer

    remove_column :vars, :cuahsi_variable_id, :integer
  end
end
