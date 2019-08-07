class AddDisplayPointsToInstruments < ActiveRecord::Migration
  def change
     add_column :instruments, :display_points, :integer, :default => 20
  end
end
