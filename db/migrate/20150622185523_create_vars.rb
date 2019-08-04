class CreateVars < ActiveRecord::Migration[5.1]
  def change
    create_table :vars do |t|
      t.string :name
      t.string :v
      t.references :instrument, index: true

      t.timestamps null: false
    end
    add_foreign_key :vars, :instruments
  end
end
