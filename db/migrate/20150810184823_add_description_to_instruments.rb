class AddDescriptionToInstruments < ActiveRecord::Migration[5.1]
  def change
    add_column :instruments, :description, :text
  end
end
