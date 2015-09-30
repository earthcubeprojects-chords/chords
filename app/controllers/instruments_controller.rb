class InstrumentsController < ApplicationController

  before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_viewing}
  
  before_action :set_instrument, only: [:show, :edit, :update, :destroy]

  def live
    
    if params[:id]
      m = Measurement.where("instrument_id = ? and parameter = ?", params[:id], params[:var]).last

      if @profile.secure_data_viewing
        authorize! :view, m
      end

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
    # 

    @instruments = Instrument.all

    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @instruments[0]
    end    
    
    @sites = Site.all
  end
  
  # GET /instruments/duplicate?instrument_id=1
  def duplicate

    # Does it exist?
    if Instrument.exists?(params[:instrument_id])

      old_instrument = Instrument.find(params[:instrument_id])
      
      if @profile.secure_administration
        authenticate_user!
        authorize! :manage, old_instrument
      end
      
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
    
    redirect_to instruments_path
  end
  
  # GET /instruments
  # GET /instruments.json
  def index
    @instruments = Instrument.all
    @sites = Site.all

    if @profile.secure_data_viewing
      authorize! :view, @instruments[0]
    end

  end

  # GET /instruments/1
  # GET /instruments/1.csv
  # GET /instruments/1.jsf
  # GET /instruments/1.json
  def show
    # This method sets the following instance variables:
    #  @params
    #  @varnames       - A hash of variable names for the instrument, keyed by the shortname
    #  @varshortname   - the shortname of the selected variable. Use it to get the full variable name from @varnames
    #  @tz_name        - the timezone name
    #  @tz_offset_mins - the timezone offset, in minutes

    if @profile.secure_data_viewing
      authorize! :view, @instrument
    end

          
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

    # Get the timezone name and offset in minutes from UTC.
    @tz_name, @tz_offset_mins = ProfileHelper::tz_name_and_tz_offset
    
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
    if params.key?(:last)
      m = Measurement.where("instrument_id=?", params[:id]).order(measured_at: :desc).first
      starttime = m.measured_at
      endtime   = starttime
    else
      # if we have the start and end parameters
      if params.key?(:start)
        starttime = Time.parse(params[:start])
      end
      if params.key?(:end)
        endtime = Time.parse(params[:end])
      end
    end
    
    # get the measurements
    if params.key?(:last)
      # if 'last' was specified, use the exact time.
      measurements =  @instrument.measurements.where("measured_at = ?", starttime)
    else
      # otherwise, everything from the start time to less than the endtime.
      measurements =  @instrument.measurements.where("measured_at >= ? and measured_at < ?", starttime, endtime)
    end
    
    respond_to do |format|
      format.html
      format.csv { 
        send_data measurements.to_csv(metadata, @varnames),
          filename: file_root+'.csv' 
      }
      format.xml { 
        send_data measurements.to_xml, filename: file_root+'.xml'
      }    
      format.json { 
        # Convert metadata to a hash
        mdata = {}
        metadata.each do |m|
          mdata[m[0]] = m[1]
        end
        render json: measurements.columns_with_metadata(@varnames, mdata)
      }
      format.jsf { 
        # Convert metadata to a hash
        mdata = {}
        metadata.each do |m|
          mdata[m[0]] = m[1]
        end
        send_data measurements.columns_with_metadata(@varnames, mdata),
           filename: file_root+'.json'
      }
      
    end
  end
    
  # GET /instruments/new
  def new
    @instrument = Instrument.new

    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @instrument
    end
    
  end

  # GET /instruments/1/edit
  def edit
  end

  # POST /instruments
  # POST /instruments.json
  def create
    @instrument = Instrument.new(instrument_params)

    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @instrument
    end

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

    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @instrument
    end
        
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

    if @profile.secure_administration
      authenticate_user!
      authorize! :manage, @instrument
    end
    
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
        :name, :site_id, :display_points, :seconds_before_timeout, :description, :instrument_id)
    end

end
