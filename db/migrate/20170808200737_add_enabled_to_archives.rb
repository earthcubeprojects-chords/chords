class AddEnabledToArchives < ActiveRecord::Migration
  def change
  	add_column :archives, :enabled, :boolean, :default => false
  end
end
