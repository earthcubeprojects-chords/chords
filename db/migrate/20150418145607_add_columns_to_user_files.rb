class AddColumnsToUserFiles < ActiveRecord::Migration
  def change
    add_column :user_files, :name, :string
    add_column :user_files, :function, :string
    add_column :user_files, :data, :binary
  end
end
