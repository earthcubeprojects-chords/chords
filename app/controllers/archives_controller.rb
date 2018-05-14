class ArchivesController < ApplicationController
  include ArchiveHelper

  load_and_authorize_resource

  def enable_archiving
    authorize! :manage, Archive

    configuration_error_messages = Array.new

    if @profile.domain_name == 'example.chordsrt.com'
      configuration_error_messages.push('You must change the default domain name in the profile configuration.')
    end

    if @profile.unit_source != 'CUAHSI'
      configuration_error_messages.push("You must set the 'Units Ontology' to 'CUAHSI' in the profile configuration.")
    end

    if @profile.measured_property_source != 'CUAHSI'
      configuration_error_messages.push("You must set the 'Measured Property Ontology' to 'CUAHSI' in the profile configuration.")
    end

    if unconfigured_sources.count > 0
      configuration_error_messages.push('CUAHSI source is not configured.')
    end

    sites = ArchiveHelper::unconfigured_sites

    if sites.count > 0
      configuration_error_messages.push("#{sites.count} CUAHSI sites are not configured.")
    end

    #######
    # TO DO: check if site type is defined for each site ?
    #######

    methods = unconfigured_methods

    if methods.count > 0
      configuration_error_messages.push("#{methods.count} CUAHSI methods are not configured.")
    end

    vars = unconfigured_vars

    if vars.count > 0
      configuration_error_messages.push("#{vars.count} CUAHSI variables are not configured.")
    end

    #######
    # TO DO: check id a general category defined for each variable ?
    #######

    if configuration_error_messages.length > 0
      flash[:alert] = "The archive configuration is not complete:<br/><br/>".html_safe
      flash[:alert] << configuration_error_messages.join("<br/>").html_safe
    else
      # enable archiving
      @archive.enabled = true

      if @archive.save
        flash[:notice] = "Archiving is now enabled.<br/><br/>Data will start being transmitted to the configured archive.".html_safe
      else
        flash[:alert] = "There was an error saving the arvhive configuration"
      end
    end

    redirect_to archives_path
  end

  def disable_archiving
    authorize! :manage, Archive

    @archive.enabled = false
    @archive.save

    flash[:notice] = "Archiving is now disabled. <br/><br/>Data will no longer be transmitted to the configured archive.".html_safe

    redirect_to archives_path
  end

  def index
    if @archive == nil
      Archive.populate
      @archive = Archive.first
    end

    @archive.get_credentials
  end

  def create
    if @archive.update(archive_params)
      flash[:notice] = 'Archive configuration saved'

      return redirect_to archives_path
    else
      if !@archive.valid?
        flash.now[:alert] = @archive.errors.full_messages.to_sentence
      end

      render :index
    end
  end

  def update_credentials
    authorize! :update, Archive

    respond_to do |format|
      if @archive.update_attributes(archive_params) && @archive.update_credentials(archive_params)
        format.html{ redirect_to(archives_path, notice: 'Archive Credentials successfully updated') }
        format.json{ respond_with_bip(@archive) }
      else
        format.html{ render :index }
        format.json{ respond_with_bip(@archive) }
      end
    end
  end

  def update
    respond_to do |format|
      if @archive.update_attributes(archive_params)
        # rebuild the cron schedule of the send frequency is set.
        if @archive.send_frequency != nil
          @archive.rebuild_crontab_schedule
        end

        format.html{ redirect_to(@archive, notice: 'Configurations was successfully updated') }
        format.json{ respond_with_bip(@archive) }
      else
        format.html{ render :index }
        format.json{ respond_with_bip(@archive) }
      end
    end
  end

  def push_cuahsi_variables
    error = ""

    unconfigured_vars.each do |var|
      if var.measured_property.source != "CUAHSI"
        error = "Measured property source needs to be set to CUAHSI. Please change the portal configuration and update the variable measured properties."
        flash[:alert] = error

        return redirect_to archives_path
      elsif var.unit.source != "CUAHSI"
        error = "Unit source needs to be set to CUAHSI. Please change the portal configuration and update the variable units."
        flash[:alert] = error

        return redirect_to archives_path
      end

      data = var.create_cuahsi_variable

      if var.get_cuahsi_variableid(data["VariableCode"]) == nil
        uri_path = Rails.application.config.x.archive['base_url'] + '/default/services/api/variables'
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
        uri_path = Rails.application.config.x.archive['base_url'] + '/default/services/api/methods'
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
        uri_path = Rails.application.config.x.archive['base_url'] + '/default/services/api/sites'
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
        uri_path = Rails.application.config.x.archive['base_url'] + '/default/services/api/sources'
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
  def archive_params
    params.require(:archive).permit(:id, :name, :base_url, :send_frequency, :last_archived_at, :created_at,
                                    :updated_at, :username, :password, :enabled)
  end
end
