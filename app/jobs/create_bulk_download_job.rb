class CreateBulkDownloadJob < ApplicationJob
  queue_as :default



  def perform(*args)

    bd = BulkDownload.new(*args)

		instruments = Instrument.where(id: bd.instrument_ids) 


		# Define a unique string for this job
  	random_job_id = SecureRandom.hex(10)


  	# Define the tmp directory to store the files in
  	# tmp_dir = bd.tmp_dir
  	# processing_dir = bd.processing_dir



  	# define a few file paths
    # final_file_path           = bd.final_file_path
    # placeholder_file_path     = bd.placeholder_file_path
    # header_row_file_path      = bd.header_row_file_path
    # header_row_zip_file_path  = bd.header_row_file_path


    # Create the placehold file that indicates the creation is in process
    FileUtils.touch(bd.placeholder_file_path)


    # Generate the header row
    # Get the labels for the master csv file
    row_labels =  "# CSV file creation initiated at: #{bd.creation_time.to_s}\n"
    row_labels += "# Start Date (inclusive): #{bd.start_time.strftime('%Y-%m-%d')}\n"
    row_labels += "# End Date (inclusive):   #{bd.end_time.strftime('%Y-%m-%d')}\n"
    row_labels += "# Include Test Data: #{bd.include_test_data}\n"
    row_labels += "# Instrument IDs: #{bd.instrument_ids.join(', ')}\n"
    row_labels += "# Instrument Names: #{instruments.pluck(:name).join(', ')}\n"

    row_labels += bd.row_labels
    File.write(bd.header_row_file_path, bd.row_labels)

    # zip the temp file
    command = "gzip -f #{bd.header_row_file_path}"
    system(command)

    # track all the files that are created
  	temp_files = Array.new
  	temp_files.push(bd.header_row_zip_file_path)



  	# Create zip files for each variable of each desired instrument
		instruments.each do |instrument|

      # define a few file names

      # TheTZVOLCANOGNSSNetwork_Volcanoflank_OLO1
      # instrument_header_row_file_name       = "#{bd.random_job_id}_header_row.csv"
      # instrument_header_row_file_path       = "#{bd.processing_dir}/#{header_row_file_name}"
      # instrument_header_row_zip_file_path   = "#{bd.processing_dir}/#{header_row_file_name}.gz"

			instrument.vars.each do |var|
		
		    var_output_file_name = "#{bd.random_job_id}_instrument_#{var.instrument_id}_var_#{var.id}.csv"
		    var_output_file_path = "#{BulkDownload.processing_dir}/#{var_output_file_name}"

				zip_file_path = ExportTsPointsToFile.call(
					var,
          bd,
					var_output_file_path
				)

				if zip_file_path
					temp_files.push(zip_file_path)
				end
			end
		end


		# Merge the zip files together
		files_string = temp_files.join(" ")
		# command = "cat  #{files_string} > #{final_file_path}"
    command = "zcat #{files_string} | gzip -c > #{bd.final_file_path}"
		system(command)


  	# Remove the temp files
  	temp_files.each do |file_path|
  		File.delete(file_path)
  	end

  	File.delete(bd.placeholder_file_path)

  end
end
