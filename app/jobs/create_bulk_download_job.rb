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
		Instrument.all.each do |instrument|
			instrument.vars.each do |var|
				# puts var.id
				zip_file_path = ExportTsPointsToFile.call(TsPoint, var.id)
				puts "zip_file_path #{zip_file_path}"

			end
		end
  end
end
