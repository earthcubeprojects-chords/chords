class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :set_before_profile
  
  def set_before_profile
    
    if ! @before_profile = Profile.first
      Profile.initialize
      @before_profile = Profile.first
    end

    if @before_profile.logo != nil
      @logo_base64 = Base64.encode64(@before_profile.logo)
    else 
      @logo_base64 = nil
    end

    if ! Site.first
      Site.initialize
    end
    
    if ! Instrument.first
      Instrument.initialize
    end
    
  end
  
end
