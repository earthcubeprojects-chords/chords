class CreateSites < ActiveRecord::Migration[5.1]
  def change
    create_table :sites do |t|
      t.string :name
      t.float :lat
      t.float :lon

      t.timestamps null: false
    end
  end
end
