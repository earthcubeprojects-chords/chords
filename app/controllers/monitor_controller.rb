class MonitorController < ApplicationController

  before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_viewing}
    
  def index
    @instruments = Instrument.all

    if @profile.secure_data_viewing
      if @instruments.count > 0
        authorize! :view, @instruments[0]
      end
    end


    @data = Instrument.find(1).data(20)

  end
  
  
  def show

    if @profile.secure_data_viewing
      authorize! :view, @monitor
    end
    
  end
 
  def live
    measurement = Instrument.find(params[:instrument_id]).last_measurement

    if @profile.secure_data_viewing
      authorize! :view, measurement
    end

    if m
      render :json => measurement.json_point
    else
      render :json => nil
    end
  end
      
end
