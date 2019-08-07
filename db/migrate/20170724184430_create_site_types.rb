class CreateSiteTypes < ActiveRecord::Migration
  def change
    create_table :site_types do |t|
      t.string :name
      t.text :definition

      t.timestamps null: false
    end
  end
end
