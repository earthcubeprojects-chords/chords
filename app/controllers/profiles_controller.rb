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
        :project, :affiliation, :description, :logo, :created_at, :updated_at, :timezone, 
        :secure_administration, :secure_data_viewing, :secure_data_download, 
        :secure_data_entry, :data_entry_key, :google_maps_key
        )
    end

end
