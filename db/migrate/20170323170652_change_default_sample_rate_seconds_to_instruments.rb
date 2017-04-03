class ChangeDefaultSampleRateSecondsToInstruments < ActiveRecord::Migration
  def up
    change_column_default :instruments, :sample_rate_seconds, 60
  end
  def down
    change_column_default :instruments, :sample_rate_seconds,  5
  end
end
