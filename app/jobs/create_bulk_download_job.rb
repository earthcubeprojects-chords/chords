class CreateBulkDownloadJob < ApplicationJob
  queue_as :default

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
