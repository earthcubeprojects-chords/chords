class CreateArchives < ActiveRecord::Migration
  def change
    create_table :archives do |t|
      t.string :name
      t.string :base_url
      t.string :send_frequency
      t.datetime :last_archived_at

      t.timestamps null: false
    end
  end
end
