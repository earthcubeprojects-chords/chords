class RemoveVarnumberFromVars < ActiveRecord::Migration
  def change
    remove_column :vars, :varnumber, :string
  end
end
