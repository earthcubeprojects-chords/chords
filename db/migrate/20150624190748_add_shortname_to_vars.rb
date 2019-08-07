class AddShortnameToVars < ActiveRecord::Migration
  def change
    add_column :vars, :shortname, :string
  end
end
