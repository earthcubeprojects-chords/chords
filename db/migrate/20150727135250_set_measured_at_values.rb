class SetMeasuredAtValues < ActiveRecord::Migration
  def change
    Measurement.connection.execute("update measurements set measured_at=created_at")
  end
end
