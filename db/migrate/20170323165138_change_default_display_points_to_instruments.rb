class ChangeDefaultDisplayPointsToInstruments < ActiveRecord::Migration[5.1]
  def up
    change_column_default :instruments, :display_points, 120
  end
  def down
    change_column_default :instruments, :display_points,  20
  end
end
