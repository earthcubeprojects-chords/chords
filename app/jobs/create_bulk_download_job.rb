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

		# Define a unique string for this job
  	random_job_id = SecureRandom.hex(10)

  	# Define the tmp directory to store the files in
  	tmp_dir = BulkDownload.tmp_dir
  	processing_dir = BulkDownload.processing_dir

		# Make sure the tmp dir exists
  	require 'fileutils'
  	FileUtils.mkpath(processing_dir)


  	# define a few file names
    header_row_file_name = "#{random_job_id}_header_row.csv"
    header_row_file_path = "#{processing_dir}/#{header_row_file_name}"
    header_row_zip_file_path = "#{processing_dir}/#{header_row_file_name}.gz"

    time_string 		= Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    final_file_name = "bulk_download_#{time_string}.csv.gz"
    final_file_path = "#{tmp_dir}/#{final_file_name}"


    # Generate the header row
    # Get the labels for the master csv file
    row_labels =  "# CSV file creation initiated at: #{Time.now.to_s}\n"
    row_labels += "# Start Date (inclusive): #{start_time.strftime('%Y-%m-%d')}\n"
    row_labels += "# End Date (inclusive):   #{end_time.strftime('%Y-%m-%d')}\n"
    row_labels += "# Include Test Data: #{include_test_data}\n"
    row_labels += "# Instrument IDs: #{instrument_ids.join(', ')}\n"
    row_labels += "# Instrument Names: #{instruments.pluck(:name).join(', ')}\n"

    row_labels += BulkDownload.row_labels(site_fields, instrument_fields, var_fields)
    File.write(header_row_file_path, row_labels)

    # zip the temp file
    command = "gzip -f #{header_row_file_path}"
    system(command)

    # track all the files that are created
  	temp_files = Array.new
  	temp_files.push(header_row_zip_file_path)



  	# Create zip files for each variable of each desired instrument
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

				temp_files.push(zip_file_path)
			end
		end


		# Merge the zip files together
		files_string = temp_files.join(" ")
		command = "cat  #{files_string} > #{final_file_path}"
		system(command)


  	# Remove the temp files
  	temp_files.each do |file_path|
  		File.delete(file_path)
  	end

  end
end
