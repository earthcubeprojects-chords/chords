class CreateLinkedData < ActiveRecord::Migration
  def change
    create_table :linked_data do |t|
      t.text :name, null: false
      t.text :description, null: false
      t.text :keywords, null: false
      t.string :dataset_url
      t.string :license
      t.string :doi

      t.timestamps null: false
    end
  end
end
