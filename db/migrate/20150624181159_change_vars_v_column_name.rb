class ChangeVarsVColumnName < ActiveRecord::Migration
  def change
    rename_column :vars, :v, :varnumber
  end
end
