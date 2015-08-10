class AddDescriptionToInstruments < ActiveRecord::Migration
  def change
    add_column :instruments, :description, :text
  end
end
