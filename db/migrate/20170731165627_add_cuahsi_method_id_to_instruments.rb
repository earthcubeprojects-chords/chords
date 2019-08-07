class AddCuahsiMethodIdToInstruments < ActiveRecord::Migration
  def change
    add_column :instruments, :cuahsi_method_id, :integer
  end
end
