class RemoveVarnumberFromVars < ActiveRecord::Migration[5.1]
  def change
    remove_column :vars, :varnumber, :string
  end
end
