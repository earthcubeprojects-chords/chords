class CreateParams < ActiveRecord::Migration
  def change
    create_table :params do |t|
      t.string :name
      t.string :p
      t.references :instrument, index: true

      t.timestamps null: false
    end
    add_foreign_key :params, :instruments
  end
end
