class AddTimezoneToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :timezone, :string
  end
end
