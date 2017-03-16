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
    @profile.update(profile_params)      


    # Handle the logo stuff separately
    if params[:reset_logo].to_i == 1
      @profile.update_attribute(:logo, nil)
    else
      if params[:profile][:logo] != nil
        @profile.update_attribute(:logo, params[:profile][:logo].read)
      else
        @profile.update_attribute(:logo, @profile.logo)
      end
    end  

      
    flash[:notice] = 'Configuration saved.'
    
    redirect_to profiles_path
  end
  
  def backup
    @profiles = Profile.all
    @sites = Site.all
    @instruments = Instrument.all
    @users = User.all
    @vars = Var.all
    @measured_properties = MeasuredProperty.all
    
    file_name = "configuration_backup_of_" + @profiles[0].project.downcase.gsub(/\s/,"_").gsub(/\W/, '') + ".json"

    send_data [profiles: @profiles, sites: @sites, instruments: @instruments, vars: @vars, users: @users, measured_properties: @measured_properties].to_json  , :filename => file_name
  end
  
  def restore
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
      Var.all.destroy_all
      Instrument.all.destroy_all
      Site.all.destroy_all
      MeasuredProperty.all.destroy_all
      Profile.all.destroy_all
      
      # Rebuild the configuration based on the uploaded JSON
      ProfileHelper::replace_model_instances_from_JSON('Profile', profiles)
      ProfileHelper::replace_model_instances_from_JSON('MeasuredProperty', measured_properties)
      ProfileHelper::replace_model_instances_from_JSON('Site', sites)
      ProfileHelper::replace_model_instances_from_JSON('Instrument', instruments)
      ProfileHelper::replace_model_instances_from_JSON('Var', vars)

      
      flash[:notice] = 'The portal configuration has been sucessfully restored.'
    end
  end

  # def conditionally_authenticate_user!
  #   before_action :authenticate_user   
  # end

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
        :secure_data_entry, :data_entry_key, :google_maps_key, :backup_file
        )
    end

end
