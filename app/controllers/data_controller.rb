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
  	
  	CreateBulkDownloadJob.perform_later

    respond_to do |format|
	    format.html{ redirect_to data_bulk_download_path, notice: 'Your bulk download is being created. Please refesh this page to monitor progress.' }
    end
  end

end
