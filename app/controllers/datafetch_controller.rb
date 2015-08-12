class DatafetchController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @instruments = Instrument.all
    @sites = Site.all
  end

  def create
  end

end
