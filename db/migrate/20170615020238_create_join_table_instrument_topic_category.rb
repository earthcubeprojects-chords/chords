class CreateJoinTableInstrumentTopicCategory < ActiveRecord::Migration
  def change
    create_join_table :instruments, :topic_categories do |t|
      # t.index [:instrument_id, :topic_category_id]
      # t.index [:topic_category_id, :instrument_id]
    end
  end
end
