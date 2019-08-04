class IncreaseLastUrlSize < ActiveRecord::Migration[5.1]
  def change
    change_column :instruments, :last_url, :text
  end
end
