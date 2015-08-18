class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :set_profile
  
  def set_profile
    
    if ! @profile = Profile.first
      Profile.initialize
      @profile = Profile.first
    end

    if ! Site.first
      Site.initialize
    end
    
    if ! Instrument.first
      Instrument.initialize
    end
    
  end

  # Access denied redirect
  rescue_from "AccessGranted::AccessDenied" do |exception|
    redirect_to '/about', alert: "You don't have permissions to access this page."
  end  
end
