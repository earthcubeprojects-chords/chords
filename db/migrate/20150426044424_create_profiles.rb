class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :project,     limit: 255
      t.string :affiliation, limit: 255
      t.string :description, limit: 1000
      t.binary :logo,        limit: 1000000

      t.timestamps null: false
    end
  end
end

