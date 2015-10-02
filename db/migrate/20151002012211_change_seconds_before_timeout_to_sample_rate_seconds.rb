class ChangeSecondsBeforeTimeoutToSampleRateSeconds < ActiveRecord::Migration
  def change
     rename_column :instruments, :sample_rate_seconds, :sample_rate_seconds
  end
end
