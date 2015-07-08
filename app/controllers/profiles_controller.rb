class ProfilesController < ApplicationController
# There will only be one record in the Profiles table

  def index
    @profile = Profile.first
    
    if @profile == nil
      Profile.initialize
      @profile = Profile.first
    end
    
  end
  
  def create
    project     = params[:profile][:project]
    affiliation = params[:profile][:affiliation]
    description = params[:profile][:description]
    timezone    = params[:profile][:timezone]
    
    @profile = Profile.first
    
    @profile.update(
      project: project, 
      affiliation: affiliation, 
      description: description,
      timezone:    timezone
      )
      
    flash[:notice] = 'Configuration saved.'
    
    render "profiles/index"
  end
  
end
