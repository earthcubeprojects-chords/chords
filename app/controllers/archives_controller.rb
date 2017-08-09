class ArchivesController < ApplicationController

  before_action :set_archive
  include ArchiveHelper


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
    error = ""
    unconfigured_vars.each do |var|
      if var.measured_property.source != "CUAHSI" 
        error = "Measured property source needs to be set to CUAHSI. Please change the portal configuration and update the variable measured properties."
        flash[:alert] = error
        redirect_to archives_path
        return
      elsif var.unit.source != "CUAHSI"
        error = "Unit source needs to be set to CUAHSI. Please change the portal configuration and update the variable units."
        flash[:alert] = error
        redirect_to archives_path
        return
      end
      data = var.create_cuahsi_variable
      if var.get_cuahsi_variableid(data["VariableCode"]) == nil
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/variables"
        response = CuahsiHelper::send_request(uri_path, data)
        if (response.code.to_s != '200')
          error = response.body.to_s
        end
        var.get_cuahsi_variableid(data["VariableCode"])
      end
    end
    if unconfigured_vars.length == 0
      flash[:notice] = 'Variables successfully configured.'
    else
      flash[:alert] = 'One or more variables failed to configure. Error: ' + error
    end
    
    redirect_to archives_path
  end

  def push_cuahsi_methods
    error = ""
    unconfigured_methods.each do |instrument|
      data = instrument.create_cuahsi_method
      if instrument.get_cuahsi_methodid(data["MethodLink"]).nil?
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/methods"
        response = CuahsiHelper::send_request(uri_path, data)
        if (response.code.to_s != '200')
          error = response.body.to_s
        end
        instrument.get_cuahsi_methodid(data["MethodLink"])
      end
    end
    if unconfigured_methods.length == 0
      flash[:notice] = 'Instruments successfully configured.'
    else
      flash[:alert] = 'One or more instruments failed to configure. Error: ' + error
    end
    
    redirect_to archives_path
  end

  def push_cuahsi_sites
    error = ""
    ArchiveHelper::unconfigured_sites.each do |site|    
      data = site.create_cuahsi_site
      if site.find_site == nil
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sites"
        response = CuahsiHelper::send_request(uri_path, data)
        if (response.code.to_s != '200')
          error = response.body.to_s
        end
        site.find_site
      end
    end
    if ArchiveHelper::unconfigured_sites.length == 0
      flash[:notice] = 'Sites successfully configured.'
    else
      flash[:alert] = 'One or more sites failed to configure. Error: ' + error
    end
    
    redirect_to archives_path
  end

  def push_cuahsi_sources
    error = ""
    unconfigured_sources.each do |profile|
      data = profile.create_cuahsi_source
      if profile.get_cuahsi_sourceid(data["link"]) == nil
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sources"
        response = CuahsiHelper::send_request(uri_path, data)
        if (response.code.to_s != '200')
          error = response.body.to_s
        end
        profile.get_cuahsi_sourceid(data["link"])
      end
    end

    if unconfigured_sources.length == 0
      flash[:notice] = 'Sources successfully configured.'
    else
      flash[:alert] = 'One or more sources failed to configure. Error ' + error
    end
    
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


