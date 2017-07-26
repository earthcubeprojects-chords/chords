json.extract! archive_job, :id, :archive_name, :start_at, :end_at, :status, :message, :created_at, :updated_at
json.url archive_job_url(archive_job, format: :json)