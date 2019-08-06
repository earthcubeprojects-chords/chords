class CreateTopicCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :topic_categories do |t|
      t.string :name
      t.text :definition

      t.timestamps null: false
    end
  end
end
