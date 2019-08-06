class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units do |t|
      t.string :name
      t.string :abbreviation

      t.timestamps null: false
    end
  end
end
