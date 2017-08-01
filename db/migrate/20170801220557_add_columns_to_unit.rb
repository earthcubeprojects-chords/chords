class AddColumnsToUnit < ActiveRecord::Migration
  def change
    add_column :units, :id_num, :integer
    add_column :units, :unit_type, :string
  end
end
