class CreateArchiveJobs < ActiveRecord::Migration
  def change
    create_table :archive_jobs do |t|
      t.string :archive_name
      t.datetime :start_at
      t.datetime :end_at
      t.string :status
      t.text :message

      t.timestamps null: false
    end
  end
end
