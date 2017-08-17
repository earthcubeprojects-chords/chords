class CreateJoinTableInstrumentTopicCategory < ActiveRecord::Migration
  def change
    add_column :instruments, :topic_category_id, :integer
  end
end
