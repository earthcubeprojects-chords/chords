class BulkDownloadController < ApplicationController

  def index
    authorize! :manage, :bulk_download

    @sites = Site.accessible_by(current_ability)
    @instruments = Instrument.accessible_by(current_ability)
    @db_expiry_time = ApplicationHelper.db_expiry_time

    @bulk_download_files = Dir["/tmp/bulk_downloads/*.gz"].sort
    @placeholder_files   = Dir["/tmp/bulk_downloads/*.temp"].sort

    @space_left_on_system = `df --block-size=1 .`.split[10]
  end


  def download
		authorize! :manage, :bulk_download

		# Make sure that the user isn't trying to gain unauthorized access by reomving everything but the base file name
  	file_name = File.basename(params[:file])

  	file_path = "#{BulkDownload.tmp_dir}/#{file_name}"

  	if File.exists?(file_path)
	  	send_file  file_path
	  else
	  	flash[:notice] = 'That file has been deleted.'
	  	redirect_to bulk_download_path
	  end
  end


  def create
		authorize! :manage, :bulk_download


    # Get the instrument ids
    sanitized_instrument_ids = params[:instruments].gsub(/[^\w\,]/, '').split(',')

    if sanitized_instrument_ids.count < 1
    	sanitized_instrument_ids = Instrument.accessible_by(current_ability).pluck(:id)
    end


		# sanitize user input
		santized_start 							= params[:start].gsub(/[^\:\-\w\.]/, '')
		santized_end 								= params[:end].gsub(/[^\:\-\w\.]/, '')
		santized_include_test_data  = params[:include_test_data] == 'true' ? true : false
    
    create_separate_instrument_files  = params[:create_separate_instrument_files] == 'true' ? true : false
    include_full_metadata_on_all_rows = params[:include_full_metadata_on_all_rows] == 'true' ? true : false

		sanitized_site_fields 			= params[:site_fields].gsub(/[^\,\w\.]/, '').split(',')
		sanitized_instrument_fields = params[:instrument_fields].gsub(/[^\,\w\.]/, '').split(',')
		sanitized_var_fields 				= params[:var_fields].gsub(/[^\,\w\.]/, '').split(',')


  	CreateBulkDownloadJob.perform_later(
  		santized_start, 
  		santized_end, 
  		sanitized_instrument_ids, 
  		santized_include_test_data,
  		sanitized_site_fields,
  		sanitized_instrument_fields,
  		sanitized_var_fields,
      create_separate_instrument_files,
      include_full_metadata_on_all_rows
  	)


		render json: {}, status: 200
    # respond_to do |format|
    # 	format.json { head :ok }
	   #  # format.html{ redirect_to bulk_download_path, notice: 'Your bulk download is being created. Please refesh this page to monitor progress.' }
    # end
  end


  def destroy
		authorize! :manage, :bulk_download

  	file_name = File.basename(params[:file])
  	file_path = "#{BulkDownload.tmp_dir}/#{file_name}"

  	File.delete(file_path) if File.exist?(file_path)

    redirect_to bulk_download_path, notice: "#{file_name} has been deleted." 
  end

end