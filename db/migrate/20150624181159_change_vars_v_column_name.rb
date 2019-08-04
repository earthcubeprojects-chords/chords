class ChangeVarsVColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :vars, :v, :varnumber
  end
end
