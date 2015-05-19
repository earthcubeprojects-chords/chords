class MonitorController < ApplicationController

  def index
    @instruments = Instrument.all

    measurements = Measurement.where("instrument_id = ?", 1).last(20)
    

    data = Array.new    
    measurements.each do |measurement|
      t = Time.new(measurement.created_at.year, measurement.created_at.month, measurement.created_at.day, measurement.created_at.hour, measurement.created_at.min, measurement.created_at.sec, "+07:00")

      x=((t.to_i) * 100).to_s
      data.push "[#{x}, #{measurement.value}]" 
      # x=ActiveSupport::JSON
      # @j=x.encode(ret)
      
    end
@data = data.join(', ')

    @time = ((t.to_i) * 100).to_s
  end
  
  
  def show
  end
    
  def live
    measurement = Measurement.last
    x = Time.now.to_i * 1000

    measurement = Measurement.last
    t = Time.new(measurement.created_at.year, measurement.created_at.month, measurement.created_at.day, measurement.created_at.hour, measurement.created_at.min, measurement.created_at.sec, "+07:00")

# x=miliseconds
x=(t.to_i * 100).to_s
# 1432007770000,10.9686
    y = Random.rand(11)
    #create an array and echo to JSON
    ret =[x,measurement.value]
    x=ActiveSupport::JSON
    @j=x.encode(ret)

    render :json => @j
  end
      
end
