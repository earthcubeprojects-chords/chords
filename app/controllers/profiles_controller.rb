class ProfilesController < ApplicationController
  # There will only be one record in the Profiles table

  before_action :authenticate_user!, :if => proc {|c| @profile.secure_administration}


  def index
    if (@profile.secure_administration == true) 
      authorize! :manage, @profile
    end
    
    if @profile == nil
      Profile.initialize
      @profile = Profile.first
    end
    
  end


  def create
    if (@profile.secure_administration == true) 
      authorize! :manage, @profile
    end
  
    @profile.update(profile_params)      
      
    flash[:notice] = 'Configuration saved.'
    
    render "profiles/index"
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
        :secure_data_entry, :data_entry_key
        )
    end

end