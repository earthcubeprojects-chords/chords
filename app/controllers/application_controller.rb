class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :set_global, :set_access_control_header

  before_action :authenticate_user!
  
  def set_access_control_header
    headers['Access-Control-Allow-Origin'] = '*'
  end
  
  
  def set_global
    ActionMailer::Base.default_url_options = {:host => request.host_with_port}
      
    notavailmsg = "unknown"
    @chords_release  = ENV.fetch('DOCKER_TAG'           , notavailmsg)
    @source_revision = ENV.fetch('CHORDS_GIT_SHA'       , notavailmsg) [0..6]
    @source_branch   = ENV.fetch('CHORDS_GIT_BRANCH'    , notavailmsg)
    @build_time      = ENV.fetch('CHORDS_BUILD_TIME'    , notavailmsg)
    @kernel_release  = ENV.fetch('CHORDS_KERNEL_RELEASE', notavailmsg)
    @kernel_version  = ENV.fetch('CHORDS_KERNEL_VERSION', notavailmsg)
    @machine         = ENV.fetch('CHORDS_MACHINE'       , notavailmsg)
    @rails_env       = Rails.env
    @rails_version   = Rails::VERSION::STRING
    @system_uptime   = ApplicationHelper.system_uptime
    @server_uptime   = ApplicationHelper.server_uptime
    
    if ! @profile = Profile.first
      Profile.initialize
      @profile = Profile.first
    end

    if @profile.logo != nil
      @logo_base64 = @profile.logo
    else 
      @logo_base64 = nil
    end

    if ! Site.first
      Site.initialize
    end
    
    if ! Instrument.first
      Instrument.initialize
    end
    
    # ALWAYS require a user to be logged in and be an administrator in order to 
    # edit anything
    # 'secure administration' should evetually be removed from the profile model entirely
    @profile.secure_administration = true
  end


  def authenticate_user!(*args)
    current_user.present? || super(*args)
  end


  def authorize!(*args)

    @data_download_actions = ['show']
    
    if @data_download_actions.include?(action_name) && params.key?(:key) && params[:key] == @profile.data_entry_key
      # skip the authorization if the security key is provided
    else
      super(*args)
            # authorize! :download, @instrument
    end

  end


    
    
  def current_user
    if super
      user = super
    else
      user = User.new
      user.is_administrator = false

      # If data viewing / downloading is secured, set the anonymous user permissions so they can't access
      # secured functionality
      user.is_data_viewer = !(@profile.secure_data_viewing)
      user.is_data_downloader = !(@profile.secure_data_download)
# Rails.logger.debug user.is_data_downloader
    end

    user
  end
  
  
  # Access denied redirect
  rescue_from "AccessGranted::AccessDenied" do |exception|
    redirect_to '/about', alert: "You don't have permission to access this page. Do you need to sign in?"
  end  
end
