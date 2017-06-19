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
      flash.now[:alert] = "Invalid field(s). Please try again."
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
    @profiles = Profile.all
    @sites = Site.all
    @instruments = Instrument.all
    # @users = User.all
    @vars = Var.all
    @measured_properties = MeasuredProperty.all
    
    file_name = @profiles[0].project.downcase.gsub(/\s/,"_").gsub(/\W/, '') + "_chords_conf_"  + Date.today.to_s + ".json"

    send_data [profiles: @profiles, sites: @sites, instruments: @instruments, vars: @vars, measured_properties: @measured_properties].to_json  , :filename => file_name
  end
  
  def import_configuration
    if (params[:backup_file])

      # read and parse the JSON file
      file = params[:backup_file]

      file_content = file.read      

      backup_hash = JSON.parse(file_content)


      profiles = backup_hash[0]['profiles']
      sites = backup_hash[0]['sites']
      instruments = backup_hash[0]['instruments']
      users = backup_hash[0]['users']
      vars = backup_hash[0]['vars']
      measured_properties = backup_hash[0]['measured_properties']

      # Delete all records from the database
      # Thor order is important here, as there are foreign keys in place
      Var.delete_all
      Instrument.delete_all
      Site.delete_all
      MeasuredProperty.delete_all
      Profile.delete_all
      # User.delete_all
      
      
      # Rebuild the configuration based on the uploaded JSON
      ProfileHelper::replace_model_instances_from_JSON('Profile', profiles)
      # ProfileHelper::replace_model_instances_from_JSON('User', users)
      ProfileHelper::replace_model_instances_from_JSON('MeasuredProperty', measured_properties)
      ProfileHelper::replace_model_instances_from_JSON('Site', sites)
      ProfileHelper::replace_model_instances_from_JSON('Instrument', instruments)
      ProfileHelper::replace_model_instances_from_JSON('Var', vars)

      # Delete all mesurements from influxdb
      series = TsPoint.series.map {|x| x.to_s}[0]
      dropQuery = "drop series FROM \"#{series}\""
      queryresult = Influxer.client.query(dropQuery)
      
      flash[:notice] = 'The portal configuration has been sucessfully restored.'
    end
  end
  
  def export_influxdb
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
    
    Rails.logger.debug 'Profiles:upload_logo!'
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
        :secure_data_entry, :data_entry_key, :google_maps_key, :backup_file, :doi
        )
    end

end
