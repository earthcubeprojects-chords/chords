class SetMeasuredAtValues < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE measurements SET measured_at=created_at;
    SQL
  end
end
