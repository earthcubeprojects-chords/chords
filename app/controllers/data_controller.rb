class DataController < ApplicationController

  def index
    @instruments = Instrument.all

    authorize! :download, Instrument
    
    @sites = Site.all
  end

  def create
  end

end
