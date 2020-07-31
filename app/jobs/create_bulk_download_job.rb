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
    temp_file_paths = Array.new


    if (bd.create_single_master_file)
      # Create the header for the master/final csv file 
      # (If one will be created)
      header_row_zip_file_path = bd.create_master_csv_header_zip_file
      temp_file_paths.push(header_row_zip_file_path)
    end



  	# Create zip files for each variable of each desired instrument
		bd.instruments.each do |instrument|

      if (bd.create_separate_instrument_files)
        var_zip_files = Array.new

        instrument_header_row_zip_file_path = bd.create_instrument_csv_header_zip_file(instrument)
        var_zip_files.push(instrument_header_row_zip_file_path)

        # Rails.logger.debug "*" * 80
        # Rails.logger.debug var_zip_files
        # Rails.logger.debug "*" * 80

      end


			instrument.vars.each do |var|
		    var_output_file_path = bd.var_temp_output_file_path(var)

				zipped_var_file_path = ExportTsPointsToFile.call(var, bd, var_output_file_path)

				if zipped_var_file_path # Make sure the file is created - it was not if there were no data point

          if (bd.create_separate_instrument_files)
            var_zip_files.push(zipped_var_file_path)
          else
            temp_file_paths.push(zipped_var_file_path)
          end					
				end
			end

      # If separate instrument files are being created, create the instrument specifix zip file
      if (bd.create_separate_instrument_files)

        instrument_zip_file_path = bd.instrument_zip_file_path(instrument)

        # create the instument zip file by merging the var files
        files_string = var_zip_files.join(" ")
        # command = "cat  #{files_string} > #{final_file_path}"
        command = "zcat #{files_string} | gzip -c > #{instrument_zip_file_path}"
        system(command)

        # Add the instrument file to the list of files to tar at the end of the process
        temp_file_paths.push(instrument_zip_file_path)


        # Remove the temp var files
        var_zip_files.each do |file_path|
          Rails.logger.debug file_path

          File.delete(file_path)
        end

      end
		end


    if (bd.create_separate_instrument_files)

      temp_file_names = Array.new
      temp_file_paths.each do |temp_file_path|
        temp_file_names.push(File.basename(temp_file_path))
      end
      files_string = temp_file_names.join(" ")

      # create a tar file of all the 
      command = "tar czf #{bd.final_tar_file_path} -C #{BulkDownload.processing_dir} #{files_string}"
      results = system(command)
    else
      # Merge the zip files together (this if for the one singe file creation)
      files_string = temp_file_paths.join(" ")
      # command = "cat  #{files_string} > #{final_file_path}"
      command = "zcat #{files_string} | gzip -c > #{bd.final_gz_file_path}"
      system(command)
    end

    # Remove the temp files
    temp_file_paths.each do |file_path|
      File.delete(file_path)
    end


  	File.delete(bd.placeholder_file_path)

  end
end
