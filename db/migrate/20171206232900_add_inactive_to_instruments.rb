class AddInactiveToInstruments < ActiveRecord::Migration
  def change
    add_column :instruments, :inactive, :boolean, :default => false
  end
end
