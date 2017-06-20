class CreateTopicCategories < ActiveRecord::Migration
  def change
    create_table :topic_categories do |t|
      t.string :name
      t.text :definition

      t.timestamps null: false
    end
  end
end
