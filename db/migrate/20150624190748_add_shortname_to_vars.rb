class AddShortnameToVars < ActiveRecord::Migration[5.1]
  def change
    add_column :vars, :shortname, :string
  end
end
