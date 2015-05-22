class MonitorController < ApplicationController

  def index
    @instruments = Instrument.all

    @data = Instrument.find(1).data(20)
  end
  
  
  def show
  end
    
  def live
    instrument_id = 1
    render :json => Instrument.find(instrument_id).last_measurement.json_point    
  end
      
end
