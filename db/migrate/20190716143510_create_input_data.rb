class CreateInputData < ActiveRecord::Migration[5.2]
  def change
    create_table :input_data do |t|
      t.string :name
      t.float :origin_lat, default: 32.492128
      t.float :origin_lon, default: -96.997321
      t.datetime :scanned_at
      t.text :header_metadata

      t.timestamps
    end
  end
end
