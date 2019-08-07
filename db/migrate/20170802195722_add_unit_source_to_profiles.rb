class AddUnitSourceToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :unit_source, :string, default: 'CUAHSI'
  end
end
