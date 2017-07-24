class ProfilesController < ApplicationController
  # There will only be one record in the Profiles table


  # GET /profiles
  def index
    authorize! :manage, Profile
    
    if @profile == nil
      Profile.initialize
      @profile = Profile.first
    end
    
  end


# POST /profile

  def create
    authorize! :manage, Profile
  
    # update attributes
    if !@profile.update(profile_params)
      if (! @profile.valid?)
        flash.now[:alert] = @profile.errors.full_messages.to_sentence
      end

      render :index
      return
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

      
    flash[:notice] = 'Configuration saved.'
    
    redirect_to profiles_path
  end
  
  def export_configuration
    authorize! :manage, Profile
    
    @profiles = Profile.all
    @sites = Site.all
    @instruments = Instrument.all
    # @users = User.all
    @influxdb_tags = InfluxdbTag.all
    @vars = Var.all
    @measured_properties = MeasuredProperty.all
    
    file_name = @profiles[0].project.downcase.gsub(/\s/,"_").gsub(/\W/, '') + "_chords_conf_"  + Date.today.to_s + ".json"

    send_data [profiles: @profiles, sites: @sites, instruments: @instruments, vars: @vars, measured_properties: @measured_properties].to_json  , :filename => file_name
  end
  
  def import_configuration
    authorize! :manage, Profile
    
    if (params[:backup_file])

      # read and parse the JSON file
      file = params[:backup_file]

      file_content = file.read      

      backup_hash = JSON.parse(file_content)

      # The order is important here, as there are foreign keys in place
      models = [Var, InfluxdbTag, Instrument, Site, Profile, MeasuredProperty]
      

      # delete the existing configuration
      # BUT ONLY FOR THE MODELS PRESENT IN THE CONFIG FILE
      models.each do |model|        
        if backup_hash[0].key?(model.model_name.plural)

          # Delete all records from the database
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
      
      flash[:notice] = 'The portal configuration has been sucessfully restored.'
    end
  end
  
  def export_influxdb
    authorize! :manage, Profile
    
    command = "docker exec -i chords_influxdb influx_inspect export -database chords_ts_#{Rails.env} -datadir /var/lib/influxdb/data -waldir /var/lib/influxdb/wal -out /tmp/chords-influxdb-backup -compress"
    
    command_thread = Thread.new do
      system(command) 
    end
    command_thread.join
    # output = `#{actual_command}`
    # sleep(5)
    # system(command)

    # render text: "OUTPUT\n" + output.to_s
    temp_file_path = '/tmp/chords-influxdb-backup'

    export_filename = @profile.project.downcase.gsub(/\s/,"_").gsub(/\W/, '') + '_chords_influxdb_export_' + Date.today.to_s + '.zip'

    File.open(temp_file_path, 'r') do |f|
      send_data f.read, type: "application/zip", filename: export_filename
    end

    File.delete(temp_file_path)
  end  

  def import_influxdb
    authorize! :manage, Profile
    
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
    
      flash[:notice] = 'The InfluxDB data have been imported.'
    end

  end

  # def conditionally_authenticate_user!
  #   before_action :authenticate_user   
  # end

  def upload_logo
    authorize! :manage, Profile
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_profile
    #   @profile = Profile.first
    # end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(
        :project, :affiliation, :page_title, :description, :logo, :created_at, :updated_at, :timezone, 
        :secure_administration, :secure_data_viewing, :secure_data_download, 
        :secure_data_entry, :data_entry_key, :google_maps_key, :backup_file, :doi,
        :contact_name, :contact_phone, :contact_email, :contact_address, :contact_city, :contact_state, :contact_country, :contact_zipcode
        )
    end

end





