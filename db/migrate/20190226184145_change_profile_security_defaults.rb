class ChangeProfileSecurityDefaults < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:profiles, :secure_data_viewing, 0)
    change_column_default(:profiles, :secure_administration, 1)
  end
end
