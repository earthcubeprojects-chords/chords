class MeasurementsController < ApplicationController

  #before_action :authenticate_user!, :if => proc {|c| @profile.secure_data_viewing}

  before_action :set_measurement, only: [:show, :edit, :update, :destroy]

  # GET /measurements
  # GET /measurements.json
  def index

    @measurements = Measurement.all

    if @profile.secure_data_viewing
      if @measurements.count > 0
        authorize! :view, @measurements[0]
      end
    end

    @sites = Site.all
    @instruments = Instrument.all
    
    respond_to do |format|
      format.html
      format.csv { send_data @measurements.to_csv }
    end
  end

  # GET /measurements/1
  # GET /measurements/1.json
  def show
    
    if @profile.secure_data_viewing
      authorize! :view, @measurement
    end

  end

  # GET /measurements/new
  def new
    @measurement = Measurement.new

    if @profile.secure_administration
      authorize! :view, @measurement
    end
    
  end

  # GET /measurements/1/edit
  def edit
    if @profile.secure_administration
      authorize! :view, @measurement
    end
  end

  # POST /measurements
  # POST /measurements.json
  def create
    @measurement = Measurement.new(measurement_params)

    if @profile.secure_data_entry
      authorize! :view, @measurement
    end


    respond_to do |format|
      if @measurement.save
        format.html { redirect_to @measurement, notice: 'Measurement was successfully created.' }
        format.json { render :show, status: :created, location: @measurement }
      else
        format.html { render :new }
        format.json { render json: @measurement.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET 'measurements/url_create?<many params>
  # Params:
  # test
  # instrument_id
  # shortname=val
  # at=iso8061
  # var_at=iso801
  def url_create

    # secure the creation of new measurements
    if @profile.secure_data_entry
      unless @profile.data_entry_key == params[:key]
        return
      end
    end
    

    # Are the data submitted in this query a test?
    is_test_value = false
    if params.key?(:test)
      is_test_value = true
    end
    
    # Save the url that invoked us
    Instrument.update(params[:instrument_id], :last_url => request.original_url)

    # Create an array containing the names of legitimate variable names
    measured_at_parameters = Array.new
    variable_shortnames = Array.new
    
    Instrument.find(params[:instrument_id]).vars.each do |var|
      measured_at_parameters.push(var.measured_at_parameter)
      variable_shortnames.push(var.shortname)
      
      # see if the parameter was submitted
      
      if params.include? var.shortname

        if params.key?(var.measured_at_parameter)
          measured_at = params[var.measured_at_parameter]
        elsif params.key?(var.at_parameter)
          measured_at = params[var.at_parameter]
        elsif params[:at]
          measured_at = params[:at]
        else           
          measured_at = Time.now  
        end
        # Create a new measurement
        @measurement = Measurement.new(
          :measured_at   => measured_at,
          :instrument_id => params[:instrument_id], 
          :test          => is_test_value,
          :parameter     => var.shortname, 
          :value         => params[var.shortname])
        @measurement.save
      end
    end

    respond_to do |format|
      if @measurement.save
        format.html { render text: "OK"  }
        format.json { render :show, status: :created, location: @measurement }
      else
        format.html { render :new }
        format.json { render json: @measurement.errors, status: :unprocessable_entity }
      end
    end
  end  

  # GET 'measurements/delete_test?instrument_id=1
  def delete_test
    # NEED TO ADD AUTHORIZATION

    if params.key?(:instrument_id)
      inst_id = params[:instrument_id]
      if Instrument.exists?(inst_id)
        Measurement.where(instrument_id: inst_id, test: '1').delete_all
      end
    end
    
    respond_to do |format|
      format.html { head :no_content }
      format.json { head :no_content }
    end
    
  end

  # GET 'measurements/trim?end=date
  def trim
    # NEED TO ADD AUTHORIZATION
    
    notice_text = nil
    if params.key?(:end)
      puts 'trim measurements before ' + params[:end]
      Measurement.where("measured_at < ?", params[:end]).delete_all    
      notice_text = 'Measurements before ' + params[:end] + ' were deleted.'
    end
    
    redirect_to data_path, notice: notice_text
    
  end

  # PATCH/PUT /measurements/1
  # PATCH/PUT /measurements/1.json
  def update

    if @profile.secure_administration
      authorize! :view, @measurement
    end
    
    respond_to do |format|
      if @measurement.update(measurement_params)
        format.html { redirect_to @measurement, notice: 'Measurement was successfully updated.' }
        format.json { render :show, status: :ok, location: @measurement }
      else
        format.html { render :edit }
        format.json { render json: @measurement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /measurements/1
  # DELETE /measurements/1.json
  def destroy

    if @profile.secure_administration
      authorize! :view, @measurement
    end
    
    @measurement.destroy
    respond_to do |format|
      format.html { redirect_to measurements_url, notice: 'Measurement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measurement
      @measurement = Measurement.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measurement_params
      params.require(:measurement).permit(:instrument_id, :parameter, :value, :unit, :measured_at, :test, :end)
    end
end
