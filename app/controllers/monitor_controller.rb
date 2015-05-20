class MonitorController < ApplicationController

  def index
    @instruments = Instrument.all

    measurements = Measurement.where("instrument_id = ?", 1).last(20)
    

    data = Array.new    
    measurements.each do |measurement|
      t = Time.new(measurement.created_at.year, measurement.created_at.month, measurement.created_at.day, measurement.created_at.hour, measurement.created_at.min, measurement.created_at.sec, "+00:00")

      x=((t.to_i) * 1000).to_s
      data.push "[#{x}, #{measurement.value}]" 
      
    end
    @data = data.join(', ')


  end
  
  
  def show
  end
    
  def live


    measurement = Measurement.where("instrument_id = ?", 1).order(:created_at).last
    time = Time.new(measurement.created_at.year, measurement.created_at.month, measurement.created_at.day, measurement.created_at.hour, measurement.created_at.min, measurement.created_at.sec, "+00:00")

    milliseconds = ((time.to_i) * 1000).to_s

    #create an array and echo to JSON
    ret =[milliseconds.to_i,measurement.value]

    @j=ActiveSupport::JSON.encode(ret)

    render :json => @j
  end
      
end
