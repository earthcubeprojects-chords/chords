class AddSensorIdToInstruments < ActiveRecord::Migration[5.1]
  def change
    add_column :instruments, :sensor_id, :string, false: true
    add_index  :instruments, :sensor_id, unique: true
  end
end
