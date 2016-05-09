class MonitorController < ApplicationController

  before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_viewing}
    
  def index
    authorize! :view, Instrument

    @instruments = Instrument.all

    @data = Instrument.find(1).data(20)

  end
  
  
  def show

    if @profile.secure_data_viewing
      authorize! :view, @monitor
    end
    
  end
 
  def live
    authorize! :view, Measurement

    measurement = Instrument.find(params[:instrument_id]).last_measurement

    if m
      render :json => measurement.json_point
    else
      render :json => nil
    end
  end
      
end
