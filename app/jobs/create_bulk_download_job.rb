class CreateBulkDownloadJob < ApplicationJob
  queue_as :default



  def perform(*args)

    bd = BulkDownload.new(*args)


  	# define a few file paths
    # final_file_path           = bd.final_file_path
    # placeholder_file_path     = bd.placeholder_file_path
    # header_row_file_path      = bd.header_row_file_path
    # header_row_zip_file_path  = bd.header_row_file_path


    # Create the placehold file that indicates the creation is in process
    FileUtils.touch(bd.placeholder_file_path)


    # track all the files that are created
    temp_files = Array.new


    # Create the header for the master/final csv file 
    # (If one will be created)
    header_row_zip_file_path = bd.create_master_csv_header_zip_file
  	temp_files.push(header_row_zip_file_path)



  	# Create zip files for each variable of each desired instrument
		bd.instruments.each do |instrument|

      # define a few file names

      # TheTZVOLCANOGNSSNetwork_Volcanoflank_OLO1
      # instrument_header_row_file_name       = "#{bd.random_job_id}_header_row.csv"
      # instrument_header_row_file_path       = "#{bd.processing_dir}/#{header_row_file_name}"
      # instrument_header_row_zip_file_path   = "#{bd.processing_dir}/#{header_row_file_name}.gz"

			instrument.vars.each do |var|
		
		    var_output_file_path = bd.var_temp_output_file_path(var)

				zipped_var_file_path = ExportTsPointsToFile.call(
					var,
          bd,
					var_output_file_path
				)

				if zipped_var_file_path # Make sure the file is created - it was not if there were no data point
					temp_files.push(zipped_var_file_path)
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
