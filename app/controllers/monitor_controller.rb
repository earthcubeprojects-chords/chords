class MonitorController < ApplicationController
  before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_viewing}

  def index
    authorize! :read, Instrument

    @instruments = Instrument.accessible_by(current_ability)
    @data = Instrument.find(1).data(20)   # TODO: What in the world was this supposed to be doing??
  end

  def show
    authorize! :read, :monitor
  end

  def live
    authorize! :read, :measurement

    measurement = Instrument.accessible_by(current_ability).find(params[:instrument_id]).last_measurement

    # TODO: Clean this up
    if measurement
      render :json => measurement.json_point
    else
      render :json => nil
    end
  end
end
