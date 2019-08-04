class AddTimezoneToProfile < ActiveRecord::Migration[5.1]
  def change
    add_column :profiles, :timezone, :string
  end
end
