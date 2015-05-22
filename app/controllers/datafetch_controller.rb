class DatafetchController < ApplicationController
  def index
    @instruments = Instrument.all
    @sites = Site.all
  end

  def create
  end

end
