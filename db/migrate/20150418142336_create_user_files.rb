class CreateUserFiles < ActiveRecord::Migration
  def change
    create_table :user_files do |t|

      t.timestamps null: false
    end
  end
end
