class AddSourceToUnits < ActiveRecord::Migration[5.1]
  def change
    add_column :units, :source, :string
  end
end
