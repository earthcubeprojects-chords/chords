class AddIsActiveToInstruments < ActiveRecord::Migration[5.1]
  def change
    add_column :instruments, :is_active, :boolean, :default => true
  end
end
