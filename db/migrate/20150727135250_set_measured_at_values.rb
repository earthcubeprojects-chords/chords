class SetMeasuredAtValues < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      UPDATE measurements SET measured_at=created_at;
    SQL
  end
end
