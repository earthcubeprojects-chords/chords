class DataController < ApplicationController

  before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_download}
  
  def index
    @instruments = Instrument.all

    if @profile.secure_data_download
      if @instruments.count > 0
        authorize! :download, @instruments[0]
      end
    end
    
    @sites = Site.all
  end

  def create
  end

end
