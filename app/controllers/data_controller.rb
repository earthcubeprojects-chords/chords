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
  end

  def create_bulk_download
  	# Rails.logger.debug "*" * 80

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


  	
  	# Rails.logger.debug params['start']
  	# Rails.logger.debug params['end']
  	# Rails.logger.debug params['instruments']
  	# Rails.logger.debug params['include_test_data']

  	# Rails.logger.debug "start_time #{start_time}"
  	# Rails.logger.debug "end_time #{end_time}"
  	# Rails.logger.debug "instrument_ids #{instrument_ids}"
  	# Rails.logger.debug "instrument_ids.count #{instrument_ids.count}"
  	# Rails.logger.debug "include_test_data #{include_test_data}"

  	# Rails.logger.debug "site_fields #{site_fields}"
  	# Rails.logger.debug "instrument_fields #{instrument_fields}"
  	# Rails.logger.debug "var_fields #{var_fields}"

  	# Rails.logger.debug "*" * 80

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
