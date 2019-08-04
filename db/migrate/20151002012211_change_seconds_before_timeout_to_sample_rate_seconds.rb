class ChangeSecondsBeforeTimeoutToSampleRateSeconds < ActiveRecord::Migration[5.1]
  def change
     rename_column :instruments, :seconds_before_timeout, :sample_rate_seconds
  end
end
