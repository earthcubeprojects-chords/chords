class ArchivesController < ApplicationController

  before_action :set_archive


  # GET /archives

  def index
    authorize! :manage, Archive
    
    @archive.get_credentials
    
    if @archive == nil
      Archive.initialize
      @archive = Archive.first
    end

  end



  # PATCH/PUT /archives/1
  def create
    authorize! :manage, Archive
  
  
    # update attributes
    if !@archive.update(archive_params)
      if (! @archive.valid?)
        flash.now[:alert] = @archive.errors.full_messages.to_sentence
      end

      render :index
      return
    end

      
    flash[:notice] = 'Archive configuration saved.'
    
    redirect_to archives_path
  end
  


  # PATCH/PUT /archives/1
  # PATCH/PUT /archives/1.json
  
  def update_credentials
    authorize! :manage, Archive

    respond_to do |format|
      if @archive.update_attributes(archive_params) && @archive.update_credentials(archive_params)
        format.html { redirect_to(archives_path, :notice => 'Archive Credentials successfully updated.') }
        format.json { respond_with_bip(@archive) }
      else
        format.html { render :action => "index" }
        format.json { respond_with_bip(@archive) }
      end
    end

  end

  def update
    authorize! :manage, Archive

    respond_to do |format|
      if @archive.update_attributes(archive_params)
        
        # rebuild the cron schedule of the send frequency is set.
        if @archive.send_frequency != nil
          Rails.logger.debug('*****************')
          @archive.rebuild_crontab_schedule
        end
        
        format.html { redirect_to(@archive, :notice => 'Configurations was successfully updated.') }
        format.json { respond_with_bip(@archive) }
      else
        format.html { render :action => "index" }
        format.json { respond_with_bip(@archive) }
      end
    end
  end


  def push_cuahsi_variables
    Var.all.each do |var|
      data = var.create_cuahsi_variable
      if var.get_cuahsi_variableid(data["VariableCode"]) == nil
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/variables"
        CuahsiHelper::send_request(uri_path, data)
        var.get_cuahsi_variableid(data["VariableCode"])
      end
    end
    flash[:notice] = 'Variables successfully configured.'
    
    redirect_to archives_path
  end

  def push_cuahsi_methods
    Instrument.find_each do |instrument|
      data = instrument.create_cuahsi_method
      if instrument.get_cuahsi_methodid(data["MethodLink"]).nil?
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/methods"
        CuahsiHelper::send_request(uri_path, data)
        instrument.get_cuahsi_methodid(data["MethodLink"])
      end
    end
    flash[:notice] = 'Instruments successfully configured.'
    
    redirect_to archives_path
  end

  def push_cuahsi_sites
    Site.find_each do |site|    
      data = site.create_cuahsi_site
      if site.find_site == nil
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sites"
        response = CuahsiHelper::send_request(uri_path, data)
        site.find_site
      end
    end
    flash[:notice] = 'Sites successfully configured.'
    
    redirect_to archives_path
  end

  def push_cuahsi_sources
    Profile.all.each do |profile|
      data = profile.create_cuahsi_source
      if profile.get_cuahsi_sourceid(data["link"]) == nil
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sources"
        CuahsiHelper::send_request(uri_path, data)
        profile.get_cuahsi_sourceid(data["link"])
      end
    end
    flash[:notice] = 'Sources successfully configured.'
    
    redirect_to archives_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive
      @archive = Archive.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_params
      params.require(:archive).permit(:id, :name, :base_url, :send_frequency, :last_archived_at, :created_at, :updated_at, :username, :password)
      
      
      
    end
end


