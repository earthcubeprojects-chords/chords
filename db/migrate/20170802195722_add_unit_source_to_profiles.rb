class AddUnitSourceToProfiles < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :unit_source, :string, default: 'CUAHSI'
  end
end
