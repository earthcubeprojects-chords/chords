class CreateRadarData < ActiveRecord::Migration[5.2]
  def change
    create_table :radar_data do |t|
      t.datetime :sampled_at
      t.float :origin_lat, default: 40.123
      t.float :origin_lon, default: -101.123
      t.text :header_metadata
      t.timestamps
    end
  end
end
