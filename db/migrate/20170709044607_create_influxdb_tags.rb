class CreateInfluxdbTags < ActiveRecord::Migration
  def change
    create_table :influxdb_tags do |t|

      t.timestamps null: false
    end
  end
end
