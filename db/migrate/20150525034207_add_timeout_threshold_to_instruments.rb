class AddTimeoutThresholdToInstruments < ActiveRecord::Migration[5.1]
  def change
     add_column :instruments, :seconds_before_timeout, :integer, :default => '5'
   end
end
