class CreateInstruments < ActiveRecord::Migration
  def change
    create_table :instruments do |t|
      t.string :name
      t.references :site, index: true

      t.timestamps null: false
    end
    add_foreign_key :instruments, :sites
  end
end
