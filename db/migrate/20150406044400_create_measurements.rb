class CreateMeasurements < ActiveRecord::Migration[5.1]
  def change
    create_table :measurements do |t|
      t.references :instrument, index: true
      t.string :parameter
      t.float :value
      t.string :unit

      t.timestamps null: false
    end
    add_foreign_key :measurements, :instruments
  end
end
