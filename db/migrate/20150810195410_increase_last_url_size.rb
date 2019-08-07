class IncreaseLastUrlSize < ActiveRecord::Migration
  def change
    change_column :instruments, :last_url, :text
  end
end
