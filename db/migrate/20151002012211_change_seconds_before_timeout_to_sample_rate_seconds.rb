class ChangeSecondsBeforeTimeoutToSampleRateSeconds < ActiveRecord::Migration
  def change
     rename_column :instruments, :seconds_before_timeout, :sample_rate_seconds
  end
end
