class InstrumentsController < ApplicationController
  load_and_authorize_resource

  before_action :set_instrument, only: [:show, :live]

 # GET /instruments/1/live?var=varshortname&after=time
 # Return measurements and metadata for a given instrument, var and time period.
 # Limit the number of points returned to the instrument's display_points value.
  def live
    # Verify the parameters
    # convert the millisecond input to seconds since epoch
    if ((defined? params[:after]) && (params[:after].to_i != 0))
      start_time_ms = Time.strptime(params[:after], '%Q')
    else
      time_offset = "#{@instrument.plot_offset_value}.#{@instrument.plot_offset_units}"
      start_time_ms = @instrument.point_time_in_ms("last") - eval(time_offset)
    end

    livedata = { points: [],
                 multivariable_points: {},
                 multivariable_names: [],
                 display_points: 0,
                 refresh_msecs: 1000
               }

    livedata[:display_points] = @instrument.maximum_plot_points
    livedata[:refresh_msecs] = @instrument.refresh_rate_ms

    # If the var parameter is set, then we build and return data for only this variable.
    if (params[:var])
      variable = @instrument.find_var_by_shortname(params[:var])

      # Fetch the data
      live_points = variable.get_tspoints(start_time_ms)

      if live_points
      livedata[:points] = live_points
      end

    # otherwise we return data for all variables
    else
      @instrument.vars.each do |variable|
        livedata[:multivariable_names].push  variable.shortname
        livedata[:multivariable_points][variable.shortname] = []

        # Fetch the data
        live_points = variable.get_tspoints(start_time_ms)

        if live_points
          livedata[:multivariable_points][variable.shortname] = live_points
        end
      end
    end

    render json: ActiveSupport::JSON.encode(livedata)
  end


  # GET instruments/simulator
  def simulator
    if @profile.secure_data_entry && current_user.api_key.blank?
      flash[:notice] = 'An API Key is necessary to use the simulator. Please add one by editing the user in the Users section.'
    end

    @sites = Site.accessible_by(current_ability)
    @instruments = Instrument.accessible_by(current_ability)
  end

  # GET /instruments/duplicate?instrument_id=1
  # TODO: should be GET /instruments/[INSTRUMENT_ID]/duplicate?number_of_duplicates=[num_dups]
  def duplicate
    old_instrument = Instrument.accessible_by(current_ability).find(params[:instrument_id])
    num_dups = params[:number_of_duplicates].to_i

    if old_instrument && num_dups > 0
      num_dups.times do
        # Make a copy
        # TODO: note this is shallow copy...make sure that is valid in this context
        #       should do this in a transaction as well
        new_instrument = old_instrument.dup
        new_instrument.sensor_id = nil  # this value is unique, so we can't clone it

        if !new_instrument.name.include? "clone"
          new_instrument.name = new_instrument.name + " clone"
        end

        new_instrument.last_url = nil

        # Create duplicates of the vars
        old_instrument.vars.each do |v|
          new_var = v.dup
          new_var.save
          new_instrument.vars << new_var
        end

        new_instrument.save
      end
    end

    redirect_to instruments_path
  end

  def index
    @sites = Site.accessible_by(current_ability)
  end

  def show
    # This method sets the following instance variables:
    #  @var_to_plot    - The variable currently being plotted
    #  @tz_name        - the timezone name
    #  @tz_offset_mins - the timezone offset, in minutes
    #  @last_url       - the last url
    @last_url = InstrumentsHelper.sanitize_url(GetLastUrl.call(TsPoint, @instrument.id))

    # Get the timezone name and offset in minutes from UTC.
    @tz_name, @tz_offset_mins = ProfileHelper::tz_name_and_tz_offset

    # Set the variable to plot
    if params[:var_id]
      @var_to_plot = Var.find(params[:var_id])
    else
      if (defined? @instrument.vars.first.id)
        @var_to_plot = Var.find(@instrument.vars.first.id)
      end
    end

    # Determine the time range. Default to the most recent day
    end_time = Time.now
    start_time = end_time - 1.day

    if params.key?(:last)
      start_time = @instrument.point_time_in_ms("last")
      end_time = start_time
    else
      # See if we have the start and end parameters
      if params.key?(:start)
        start_time = Time.parse(params[:start])
      end

      if params.key?(:end)
        end_time = Time.parse(params[:end])
      end
    end

    # Get the time series points from the database
    ts_points  = GetTsPoints.call(TsPoint, "value", @instrument.id, start_time, end_time)

    respond_to do |format|
      format.html

      format.sensorml do
        topic_category = @instrument.topic_category ? @instrument.topic_category.name : ''

        render file: "app/views/instruments/sensorml.xml.haml", layout: false, locals: { topic_category: topic_category }
      end
    end
  end

  def new
  end

  def create
    if @instrument.sensor_id.blank?
      @instrument.sensor_id = nil
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

  def edit
  end

  def update
    data = instrument_params

    if data[:sensor_id].blank?
      data[:sensor_id] = nil
    end

    respond_to do |format|
      if @instrument.update(data)
        format.html { redirect_to @instrument, notice: 'Instrument was successfully updated.' }
        format.json { render :show, status: :ok, location: @instrument }
      else
        format.html { render :edit }
        format.json { render json: @instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @instrument.destroy
        format.html { redirect_to instruments_url, notice: 'Instrument was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { render :show, alert: 'Instrument could not be destroyed!' }
        format.json { render @instrument.errors, status: :bad_request }
      end
    end
  end

private
  def set_instrument
    # using a where.first clause prevents an exception being thrown if the instrument is not present or not visible to the user
    @instrument = if !params[:sensor_id].blank?
                    Instrument.accessible_by(current_ability).where(sensor_id: params[:sensor_id]).first
                  else
                    nil
                  end

    if @instrument.nil?
      @instrument = Instrument.accessible_by(current_ability).where(id: params[:id]).first
    end

    @instrument
  end

  def instrument_params
    params.require(:instrument).permit(:name, :site_id, :is_active, :display_points, :sample_rate_seconds, :description,
                                       :instrument_id, :plot_offset_value, :plot_offset_units, :topic_category_id,
                                       :sensor_id, :number_of_duplicates)
  end
end
