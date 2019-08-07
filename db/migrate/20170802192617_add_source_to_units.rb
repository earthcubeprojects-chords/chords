class AddSourceToUnits < ActiveRecord::Migration
  def change
    add_column :units, :source, :string
  end
end
