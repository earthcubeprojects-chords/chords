class InstrumentsController < ApplicationController
  before_action :set_instrument, only: [:show, :edit, :update, :destroy]

  def live
    if params[:id]
      m = Measurement.where("instrument_id = ? and parameter = ?", params[:id], params[:var]).last
    else
      m = nil
    end
    
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
    # This method sets the following instance variables:
    #  @params
    #  @varnames     - A hash of variable names for the instrument, keyed by the shortname
    #  @varshortname - the shortname of the selected variable. Use it to get the full variable name from @varnames

    @params = params.slice(:start, :end)

    # Get the instrument and variable identifiers.
    instrument_name = @instrument.name
    site_name       = @instrument.site.name
    varshortnames   = Var.all.where("instrument_id = ?", @instrument.id).pluck(:shortname)
    project         = Profile.first.project
    affiliation     = Profile.first.affiliation
    metadata = [
      ["Project", project], 
      ["Site", site_name], 
      ["Affiliation", affiliation], 
      ["Instrument", instrument_name]
    ]

    # File name root
    file_root = "#{project}_#{site_name}_#{instrument_name}"
    file_root = file_root.split.join
    
    
    # Create a hash, with shortname => name
    @varnames = {}
    varshortnames.each do |vshort|
      @varnames[vshort] = Var.all.where("instrument_id = ? and shortname = ?", @instrument.id, vshort).pluck(:name)[0]
    end

    # Specify the selected variable shortname
    if params[:var]
      if varshortnames.include? params[:var]
        @varshortname  = params[:var]
      end
    else
      # the var parameter was not supplied, so select the first variable
      if @varnames.count > 0
        @varshortname = @varnames.first[0]
      end
    end
    
    # Determine the time range
    # Default to the most recent day
    endtime   = Time.now
    starttime = endtime - 1.day
    # if we have the start and end parameters
    if params[:startsecs] && params[:endsecs]
      # if they are well formed
      if params[:endsecs].to_i >= params[:startsecs].to_i
        endtime   = Time.at(params[:endsecs].to_i).to_datetime
        starttime = Time.at(params[:startsecs].to_i).to_datetime
      end
    end
    
    respond_to do |format|
      format.html
      format.csv { 
        measurements =  @instrument.measurements.where(
          "measured_at >= ? and measured_at < ?", starttime, endtime)
        send_data measurements.to_csv(metadata, @varnames),
          filename: file_root+'.csv' 
      }
      format.xml { 
        measurements =  @instrument.measurements.where(
          "measured_at >= ? and measured_at < ?", starttime, endtime)
        send_data measurements.to_xml, filename: file_root+'.xml'
      }    
      format.json { 
        measurements =  @instrument.measurements.where(
          "measured_at >= ? and measured_at < ?", starttime, endtime)
        # Convert metadata to a hash
        mdata = {}
        metadata.each do |m|
          mdata[m[0]] = m[1]
        end
        render json: measurements.columns_with_metadata(@varnames, mdata)
      }
      
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
      params.require(:instrument).permit(
        :name, :site_id, :display_points, :seconds_before_timeout)
    end

end
