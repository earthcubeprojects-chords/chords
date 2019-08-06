class CreateInfluxdbTags < ActiveRecord::Migration[5.1]
  def change
    create_table :influxdb_tags do |t|
      t.string :name
      t.string :value

      t.references :instrument, index: true

      t.timestamps null: false
    end

  end
end