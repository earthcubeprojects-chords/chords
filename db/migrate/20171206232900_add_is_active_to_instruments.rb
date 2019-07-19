class AddIsActiveToInstruments < ActiveRecord::Migration
  def change
    add_column :instruments, :is_active, :boolean, :default => true
  end
end
