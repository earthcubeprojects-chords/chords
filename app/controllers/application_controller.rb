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

    if ! Site.first
      Site.initialize
    end
    
    if ! Instrument.first
      Instrument.initialize
    end
    
  end
  
end
