class CreateMeasuredProperties < ActiveRecord::Migration[5.1]
  def change
    create_table :measured_properties do |t|
      t.string :name
      t.string :label
      t.string :url
      t.text :definition

      t.timestamps null: false
    end
  end
end
