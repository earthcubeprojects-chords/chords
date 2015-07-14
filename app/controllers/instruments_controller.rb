class InstrumentsController < ApplicationController
  before_action :set_instrument, only: [:show, :edit, :update, :destroy]

  def live
    m = Instrument.find(params[:id]).last_measurement
    if m
      render :json => m.json_point
    else
      render :json => nil
    end
  end
  

  def simulator
    @instruments = Instrument.all
    @sites = Site.all

  end
  
  # GET /instruments
  # GET /instruments.json
  def index
    @instruments = Instrument.all
    @sites = Site.all
  end

  # GET /instruments/1
  # GET /instruments/1.json
  def show
  
    @params = params
    
    # Time select the measurements of interest
    @measurements =  @instrument.measurements.where("created_at >= ?", Time.now-1.day)
    
    # Get the instrument and variable identifiers.
    instrument_name = @instrument.name
    @varnames        = Var.all.where("instrument_id = ?", @instrument.id).pluck(:name)
    @varshortnames   = Var.all.where("instrument_id = ?", @instrument.id).pluck(:shortname)
    
    respond_to do |format|
      format.html
      format.csv { send_data @measurements.to_csv(inst_name=instrument_name, varnames=@varnames, varshortnames=@varshortnames) }
      format.xml { send_data @measurements.to_xml }    
    end
  end

    
    
  # GET /instruments/new
  def new
    @instrument = Instrument.new
  end

  # GET /instruments/1/edit
  def edit
  end

  # POST /instruments
  # POST /instruments.json
  def create
    @instrument = Instrument.new(instrument_params)

    respond_to do |format|
      if @instrument.save
        format.html { redirect_to @instrument, notice: 'Instrument was successfully created.' }
        format.json { render :show, status: :created, location: @instrument }
      else
        format.html { render :new }
        format.json { render json: @instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /instruments/1
  # PATCH/PUT /instruments/1.json
  def update
    respond_to do |format|
      if @instrument.update(instrument_params)
        format.html { redirect_to @instrument, notice: 'Instrument was successfully updated.' }
        format.json { render :show, status: :ok, location: @instrument }
      else
        format.html { render :edit }
        format.json { render json: @instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /instruments/1
  # DELETE /instruments/1.json
  def destroy
    Measurement.delete_all "instrument_id = #{@instrument.id}"
    @instrument.destroy
    respond_to do |format|
      format.html { redirect_to instruments_url, notice: 'Instrument was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instrument
      @instrument = Instrument.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def instrument_params
      params.require(:instrument).permit(:name, :site_id, :display_points, :seconds_before_timeout)
    end
    


    
end
