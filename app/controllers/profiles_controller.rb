class ProfilesController < ApplicationController
# There will only be one record in the Profiles table

  # GET /profiles
  def index
    @profile = Profile.first
    
    if @profile == nil
      Profile.initialize
      @profile = Profile.first
    end
    
  end
  
  # POST /profile
  def create
    project     = params[:profile][:project]
    affiliation = params[:profile][:affiliation]
    description = params[:profile][:description]
    timezone    = params[:profile][:timezone]
    reset_logo  = params[:reset_logo].to_i
    
    @profile = Profile.last
    
    if reset_logo == 1
      logo = nil
    else
      uploaded_io = params[:profile][:logo]
      if uploaded_io != nil
        logo =  uploaded_io.read
      end
    end
    
    @profile.update(
      project: project, 
      affiliation: affiliation, 
      description: description,
      timezone:    timezone,
      logo:        logo
      )
      
    flash[:notice] = 'Configuration saved.'
    
    redirect_to profiles_path
  end
  
end
