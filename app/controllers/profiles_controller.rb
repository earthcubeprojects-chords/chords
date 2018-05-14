class ProfilesController < ApplicationController
  ###############################################################
  # *** There should only be one record in the Profiles table ***
  ###############################################################

  load_and_authorize_resource

  def index
    if @profile == nil
      Profile.initialize
      @profile = Profile.first
    end

    @email = Rails.application.config.action_mailer.smtp_settings[:user_name]
  end

  def create
    # update attributes
    if !@profile.update(profile_params)
      if !@profile.valid?
        flash.now[:alert] = @profile.errors.full_messages.to_sentence
      end

      return render :index
    end

    # Handle the logo stuff separately
    if params[:reset_logo].to_i == 1
      @profile.update_attribute(:logo, nil)
    else
      if params[:profile][:logo_file] != nil
        image_base64 = Base64.encode64(params[:profile][:logo_file].read)
        @profile.update_attribute(:logo, image_base64)
      else
        @profile.update_attribute(:logo, @profile.logo)
      end
    end

    flash[:notice] = 'Configuration saved'

    redirect_to profiles_path
  end

  def export_configuration
    authorize! :export, Profile

    data = Array.new

    @profiles = Profile.all
    @sites = Site.all
    @instruments = Instrument.all

    @influxdb_tags = InfluxdbTag.all
    @vars = Var.all
    @measured_properties = MeasuredProperty.all

    @archives = Archive.all
    @archive_jobs = ArchiveJob.all
    @site_types = SiteType.all
    @topic_categories = TopicCategory.all
    @units = Unit.all

    file_name = @profiles[0].project.downcase.gsub(/\s/,"_").gsub(/\W/, '') + "_chords_conf_"  + Date.today.to_s + ".json"

    data_to_export = [profiles: @profiles, sites: @sites, instruments: @instruments, vars: @vars,
                      measured_properties: @measured_properties, archives: @archives, archive_jobs: @archive_jobs,
                      site_types: @site_types, topic_categories: @topic_categories, units: @units]

    send_data data_to_export.to_json, filename: file_name
  end

  def import_configuration
    authorize! :import, Profile

    if (params[:backup_file])
      # read and parse the JSON file
      file = params[:backup_file]

      file_content = file.read

      backup_hash = JSON.parse(file_content)

      # The order is important here, as there are foreign keys in place
      models = [Var, InfluxdbTag, Instrument, Site, Profile, MeasuredProperty, Archive, ArchiveJob, SiteType, TopicCategory, Unit]

      # delete the existing configuration
      # BUT ONLY FOR THE MODELS PRESENT IN THE CONFIG FILE
      models.each do |model|
        if backup_hash[0].key?(model.model_name.plural)
          # Delete all records from the database
          # TODO: Should really refactor this to not use eval!!!
          eval("#{model.model_name.name}.delete_all")
        end
      end

      # Insert the new configuration
      # BUT ONLY FOR THE MODELS PRESENT IN THE CONFIG FILE
      models.reverse.each do |model|
        if backup_hash[0].key?(model.model_name.plural)
          json = backup_hash[0][model.model_name.plural]

          # remove the model name
          if model.model_name.name == 'Profile'
            json[0]['logo'] = nil
          end

          # Rebuild the configuration based on the uploaded JSON
          ProfileHelper::replace_model_instances_from_JSON(model, json)
        end
      end

      # Delete all measurements from influxdb
      series = TsPoint.series.map {|x| x.to_s}[0]
      dropQuery = "drop series FROM \"#{series}\""
      queryresult = Influxer.client.query(dropQuery)

      flash[:notice] = 'The portal configuration has been sucessfully restored and measurements cleared'
    end
  end

  def export_influxdb
    authorize! :export, Profile

    command = "docker exec -i chords_influxdb influx_inspect export -database chords_ts_#{Rails.env} -datadir /var/lib/influxdb/data -waldir /var/lib/influxdb/wal -out /tmp/chords-influxdb-backup -compress"

    command_thread = Thread.new do
      system(command)
    end

    command_thread.join

    temp_file_path = '/tmp/chords-influxdb-backup'
    export_filename = @profile.project.downcase.gsub(/\s/,"_").gsub(/\W/, '') + '_chords_influxdb_export_' + Date.today.to_s + '.zip'

    File.open(temp_file_path, 'r') do |f|
      send_data f.read, type: "application/zip", filename: export_filename
    end

    File.delete(temp_file_path)
  end

  def import_influxdb
    authorize! :import, Profile

    if (params[:influxdb_backup_file])
      # read and parse the JSON file
      file = params[:influxdb_backup_file]

      temp_file_path = '/tmp/chords-influxdb-backup'
      FileUtils.mv(params[:influxdb_backup_file].path, temp_file_path)

      command = "docker exec -i chords_influxdb influx -username $INFLUXDB_USERNAME -password $INFLUXDB_PASSWORD -database chords_ts_#{Rails.env}  -import -compressed -precision=ns -path=/tmp/chords-influxdb-backup"

      command_thread = Thread.new do
        system(command)
      end

      command_thread.join

      File.delete(temp_file_path)

      flash[:notice] = 'The InfluxDB data have been imported'
    end
  end

  def upload_logo
    authorize! :update, Profile
  end

  def push_cuahsi_sources
    Profile.all.each do |profile|
      data = profile.create_cuahsi_source

      if profile.get_cuahsi_sourceid(data["link"]).nil?
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sources"
        CuahsiHelper::send_request(uri_path, data)
        profile.get_cuahsi_sourceid(data["link"])
      end
    end
  end

private
  def profile_params
    params.require(:profile).permit(
      :project, :affiliation, :page_title, :description, :logo, :created_at, :updated_at, :timezone,
      :secure_administration, :secure_data_viewing, :secure_data_download,
      :secure_data_entry, :data_entry_key, :google_maps_key, :backup_file, :doi,
      :contact_name, :contact_phone, :contact_email, :contact_address, :contact_city, :contact_state, :contact_country,
      :contact_zipcode, :domain_name, :unit_source, :measured_property_source, :cuahsi_source_id
      )
  end
end





