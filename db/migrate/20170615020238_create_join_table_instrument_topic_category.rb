class CreateJoinTableInstrumentTopicCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :instruments, :topic_category_id, :integer
  end
end
