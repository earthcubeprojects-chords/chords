class InstrumentsController < ApplicationController  
  before_action :set_instrument, only: [:show, :edit, :update, :destroy, :live]

 # GET /instruments/1/live?var=varshortname&after=time
 # Return measurements and metadata for a given instrument, var and time period.
 # Limit the number of points returned to the instrument's display_points value.
  def live
    # Authorize access to the measurements
    authorize! :view, Measurement
 

    # Verify the parameters

    # convert the millisecond input to seconds since epoch
    if ((defined? params[:after]) && (params[:after].to_i != 0))
      start_time_ms = Time.strptime(params[:after], '%Q')
    else
      time_offset = "#{@instrument.plot_offset_value}.#{@instrument.plot_offset_units}"
      start_time_ms = @instrument.latest_time_in_ms - eval(time_offset)
    end

    # Initialze the return value
    livedata = {
      :points         => [], 
      :display_points => 0,
      :refresh_msecs  => 1000
      }


    livedata[:display_points] = @instrument.maximum_plot_points
    livedata[:refresh_msecs]  = @instrument.refresh_rate_ms          

    if (params[:var]) 
      variable = @instrument.find_var_by_shortname(params[:var])

      # Fetch the data
      live_points = variable.get_tspoints(start_time_ms)

      if live_points
      livedata[:points] = live_points
      end
    end

    # Convert to JSON
    livedata_json = ActiveSupport::JSON.encode(livedata)
    
    # Return result
    render :json => livedata_json
  end

  
  # GET instruments/simulator
  def simulator
    authorize! :manage, Instrument
  
    # Returns:
    #  @instruments
    #  @sites

    @instruments = Instrument.all
    @sites       = Site.all
  end
  
  # GET /instruments/duplicate?instrument_id=1
  def duplicate

    # Does it exist?
    if (Instrument.exists?(params[:instrument_id]) && defined? params[:number_of_duplicates])   
      (1..params[:number_of_duplicates].to_i).each do

        old_instrument = Instrument.find(params[:instrument_id])

        authorize! :manage, old_instrument

        # Make a copy
        new_instrument = old_instrument.dup

        # Add"clone" to the name
        if !new_instrument.name.include? "clone" 
          new_instrument.name = new_instrument.name + " clone"
        end

        # Zero out the last url
        new_instrument.last_url = nil

        # Create duplicates of the vars
        old_instrument.vars.each do |v|
          new_var = v.dup
          new_var.save
          new_instrument.vars << new_var
        end

        # Save the new instrument
        new_instrument.save

      end

    end
    
    redirect_to instruments_path
  end
  
  # GET /instruments
  # GET /instruments.json
  def index
    authorize! :view, Instrument

    @instruments = Instrument.all
    @sites = Site.all


  end

  # GET /instruments/1
  # GET /instruments/1.csv
  # GET /instruments/1.jsf
  # GET /instruments/1.json
  def show
    # This method sets the following instance variables:
    #  @params
    #  @var_id_to_plot - The id of the variable currently being plotted
    #  @var_to_plot    - The variable currently being plotted
    #  @tz_name        - the timezone name
    #  @tz_offset_mins - the timezone offset, in minutes
    #  @last_url       - the last url

    authorize! :view, Instrument
    authorize! :download, @instrument if ["csv", "xml", "json", "jsf"].include?(params[:format])

    # Get and sanitize the last_url
    @last_url = InstrumentsHelper.sanitize_url(
        !@profile.secure_administration, 
        !(current_user && (can? :manage, Measurement)), 
        GetLastUrl.call(TsPoint, @instrument.id))
    @params = params.slice(:start, :end)

    # Get useful details.
    instrument_name = @instrument.name
    instrument_id   = @instrument.id
    site_name       = @instrument.site.name
    varshortnames   = Var.all.where("instrument_id = ?", @instrument.id).pluck(:shortname)
    project         = Profile.first.project
    affiliation     = Profile.first.affiliation
    varnames_by_id = {}

    Var.all.where("instrument_id = #{instrument_id}").each {|v| varnames_by_id[v[:id]] = v[:name]}

    metadata = {
      "Project"     => project, 
      "Site"        => site_name, 
      "Affiliation" => affiliation, 
      "Instrument"  => instrument_name
    }
    
    # Get the timezone name and offset in minutes from UTC.
    @tz_name, @tz_offset_mins = ProfileHelper::tz_name_and_tz_offset
    
    # File name root
    file_root = "#{project}_#{site_name}_#{instrument_name}"
    file_root = file_root.split.join
     
    # Create a hash, with shortname => name
    @varnames = {}
    varshortnames.each do |vshort|
      @varnames[vshort] = Var.all.where("instrument_id = ? and shortname = ?", instrument_id, vshort).pluck(:name)[0]
    end


    # Set the variable to plot
    if params[:var_id]
      @var_id_to_plot = params[:var_id]
      @var_to_plot = Var.find(@var_id_to_plot)
    else
      if ( defined? @instrument.vars.first.id)
        @var_id_to_plot = @instrument.vars.first.id
        @var_to_plot = Var.find(@var_id_to_plot)
      else 
        # No variable defined.
        # This leaves @var_id_to_plot and @var_to_plot undefined. 
      end      
    end
    
        
    # Determine the time range. Default to the most recent day
    endtime   = Time.now
    starttime = endtime - 1.day
    if params.key?(:last)
     last_ts_point = GetLastTsPoint.call(TsPoint, "value", instrument_id)
      if (last_ts_point)
        last_ts_point.each {|p| starttime = p["time"]}
        endtime   = starttime
      else
        starttime = Time.now
        endtime   = startime
      end
    else
      # See if we have the start and end parameters
      if params.key?(:start)
        starttime = Time.parse(params[:start])
      end
      if params.key?(:end)
        endtime = Time.parse(params[:end])
      end
    end
    
    # Get the time series points from the database
    ts_points  = GetTsPoints.call(TsPoint, "value", instrument_id, starttime, endtime)

    # Prepare result
    respond_to do |format|
      
      format.html

      format.sensorml {
        render :file => "app/views/instruments/sensorml.xml.haml", :layout => false
      }
      
      format.csv { 
        ts_csv = MakeCsvFromTsPoints.call(ts_points, metadata, varnames_by_id)
        send_data ts_csv, filename: file_root+'.csv' 
      }
      
      format.xml { 
        send_data MakeXmlFromTsPoints.call(ts_points, metadata), filename: file_root+'.xml'
      } 
         
      format.json { 
        render text: MakeJsonFromTsPoints.call(ts_points, metadata)
      }
      
      format.jsf { 
        send_data  MakeJsonFromTsPoints.call(ts_points, metadata), filename: file_root+'.json'
      }
    end
  end
    
  # GET /instruments/new
  def new
    authorize! :manage, Instrument

    @instrument = Instrument.new
  end

  # GET /instruments/1/edit
  def edit
  end

  # POST /instruments
  # POST /instruments.json
  def create
    authorize! :manage, Instrument

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
    authorize! :manage, Instrument
        
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
    authorize! :manage, Instrument
    
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
        :name, :site_id, :display_points, :sample_rate_seconds, :description, :instrument_id, :plot_offset_value, :plot_offset_units)
    end

end
