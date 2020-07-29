class DataController < ApplicationController

  def index
    authorize! :read, :data

    @sites = Site.accessible_by(current_ability)
    @instruments = Instrument.accessible_by(current_ability)
    @db_expiry_time = ApplicationHelper.db_expiry_time
  end


  def bulk_download
    authorize! :read, :data

    @sites = Site.accessible_by(current_ability)
    @instruments = Instrument.accessible_by(current_ability)
    @db_expiry_time = ApplicationHelper.db_expiry_time

    @bulk_download_files = Dir["/tmp/bulk_downloads/*.gz"].sort
    @placeholder_files   = Dir["/tmp/bulk_downloads/*.temp"].sort

    @space_left_on_system = `df --block-size=1 .`.split[10]
  end


  def send_bulk_download_file
		authorize! :read, :data

  	file_name = params[:file]
  	file_path = "#{BulkDownload.tmp_dir}/#{file_name}"

  	if File.exists?(file_path)
	  	send_file  file_path
	  else
	  	flash[:notice] = 'That file has been deleted.'
	  	redirect_to data_bulk_download_path
	  end
  end


  def delete_bulk_download_file
		authorize! :read, :data

  	file_name = params[:file]
  	file_path = "#{BulkDownload.tmp_dir}/#{file_name}"

  	File.delete(file_path) if File.exist?(file_path)

    redirect_to data_bulk_download_path, notice: "#{file_name} has been deleted." 
  end


  def create_bulk_download
		authorize! :read, :data

    # Get the instrument ids
    instrument_ids = params[:instruments].split(',')

    if instrument_ids.count < 1
    	instrument_ids = Instrument.accessible_by(current_ability).pluck(:id)
    end



    # Should test data be included?
		include_test_data = params['include_test_data'] == 'true' ? true : false

		# Site, Instrument and var field selection
		site_fields 				= params[:site_fields].split(',')
		instrument_fields 	= params[:instrument_fields].split(',')
		var_fields 					= params[:var_fields].split(',')


  	
  	CreateBulkDownloadJob.perform_later(
  		params[:start], 
  		params[:end], 
  		instrument_ids, 
  		include_test_data,
  		site_fields,
  		instrument_fields,
  		var_fields
  	)

    respond_to do |format|
	    format.html{ redirect_to data_bulk_download_path, notice: 'Your bulk download is being created. Please refesh this page to monitor progress.' }
    end
  end

end
