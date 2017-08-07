class AddDefaultValueToTopicCategoryId < ActiveRecord::Migration
  def change
  	change_column_default :instruments, :topic_category_id, 19
  end
end
