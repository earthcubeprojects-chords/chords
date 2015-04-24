class ProfilesController < ApplicationController
# There will only be one record in the Profiles table

  def index
    @profile = Profile.first
    
    if @profile == nil
      @profile = Profile.new
      @profile.project = "Unnamed Project"
      @profile.description = ""
      @profile.affiliation = ""
      @profile.save
    end
    
  end
  
  def create
    project     = params[:project]
    affiliation = params[:affiliation]
    description = params[:description]
    
    @profile = Profile.first
    
    @profile.update(
      project: project, 
      affiliation: affiliation, 
      description: description
      )

    render "profiles/index"
  end
  
end
