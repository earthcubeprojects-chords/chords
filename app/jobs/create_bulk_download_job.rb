class CreateBulkDownloadJob < ApplicationJob
  queue_as :default


  	# CreateBulkDownloadJob.perform_later(
  	# 	start_time, 
  	# 	end_time, 
  	# 	instrument_ids, 
  	# 	include_test_data,
  	# 	site_fields,
  	# 	instrument_fields,
  	# 	var_fields
  	# )

  def perform(*args)

  	Rails.logger.debug args
    # Determine the time range. Default to the most recent day
    start_time = Time.parse(args[0])
    end_time = Time.parse(args[1])
   

		instrument_ids 			= args[2]
		include_test_data		= args[3]
		site_fields					= args[4]
		instrument_fields		= args[5]
		var_fields					= args[6]

		instruments = Instrument.where(id: instrument_ids) 


  	# Rails.logger.debug "*" * 80
  	# Rails.logger.debug "start_time #{start_time}"
  	# Rails.logger.debug "end_time #{end_time}"

  	# Rails.logger.debug "instrument_ids #{instrument_ids}"
  	# Rails.logger.debug "include_test_data #{include_test_data}"

  	# Rails.logger.debug "site_fields #{site_fields}"
  	# Rails.logger.debug "instrument_fields #{instrument_fields}"
  	# Rails.logger.debug "var_fields #{var_fields}"

  	# Rails.logger.debug "instruments #{instruments}"
  	# Rails.logger.debug "instruments.count #{instruments.count}"


  	random_job_id = SecureRandom.urlsafe_base64(nil, false)
  	tmp_dir = "/tmp/bulk_downloads"
  	processing_dir = "#{tmp_dir}/processing"

  	require 'fileutils'
  	FileUtils.mkpath(processing_dir)


  	@temp_files = Array.new
  	



		instruments.each do |instrument|
			instrument.vars.each do |var|
		
		    output_file_name = "#{random_job_id}_instrument_#{var.instrument_id}_var_#{var.id}.csv"
		    output_file_path = "#{processing_dir}/#{output_file_name}"


				zip_file_path = ExportTsPointsToFile.call(
					var.id, 
					start_time, 
					end_time, 
					include_test_data, 
					site_fields, 
					instrument_fields, 
					var_fields,
					output_file_path
				)

				@temp_files.push(zip_file_path)

				puts "zip_file_path #{zip_file_path}"

			end
		end


    # Get the labels for the master csv file
    row_labels = BulkDownload.row_labels(site_fields, instrument_fields, var_fields)

  	# Rails.logger.debug "row_labels #{row_labels}"
  	# Rails.logger.debug "*" * 80


  end
end
