class CreateNetcdfData < ActiveRecord::Migration[5.2]
  def change
    create_table :netcdf_data do |t|

      t.timestamps
    end
  end
end
