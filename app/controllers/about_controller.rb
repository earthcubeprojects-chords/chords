class AboutController < ApplicationController
  helper :all
  
  def index
    notavailmsg = "unknown"
    
    @profile         = Profile.first
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
          
  end
  
  # GET about/data_urls
  # GET about/data_urls?instrument_id=1
  def data_urls
    # returns
    # @instrument
    # @varnames: a hash keyed on the shortname, containing the long name
    
    if params.key?(:instrument_id) 
      if Instrument.exists?(params[:instrument_id])
        inst_id = params[:instrument_id]
      else
      inst_id = Instrument.all.first.id
      end
    else
      inst_id = Instrument.all.first.id
    end
  
    @instrument = Instrument.find(inst_id)
    varshortnames   = Var.all.where("instrument_id = ?", inst_id).pluck(:shortname)
    # Create a hash, with shortname => name
    @varnames = {}
    varshortnames.each do |vshort|
      @varnames[vshort] = Var.all.where("instrument_id = ? and shortname = ?", inst_id, vshort).pluck(:name)[0]
    end
    
  end
  
end
