class DataController < ApplicationController

  def index
    @instruments    = Instrument.all
    @db_expiry_time = ApplicationHelper.db_expiry_time

    authorize! :download, Instrument
    
    @sites = Site.all
  end

  def create
  end

end
