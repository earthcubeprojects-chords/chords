class AddSensorIdToInstruments < ActiveRecord::Migration
  def change
    add_column :instruments, :sensor_id, :string, false: true
    add_index  :instruments, :sensor_id, unique: true
  end
end
