class AddDisplayPointsToInstruments < ActiveRecord::Migration[5.1]
  def change
     add_column :instruments, :display_points, :integer, :default => 20
  end
end
