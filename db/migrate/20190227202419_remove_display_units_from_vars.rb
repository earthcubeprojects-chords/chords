class RemoveDisplayUnitsFromVars < ActiveRecord::Migration[5.1]
  def change
    remove_column(:vars, :units)
  end
end
