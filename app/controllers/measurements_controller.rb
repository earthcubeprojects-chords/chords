require 'time'

class MeasurementsController < ApplicationController
  load_and_authorize_resource

  def index
    @sites = Site.accessible_by(current_ability)
    @instruments = Instrument.accessible_by(current_ability)

    respond_to do |format|
      format.html
      format.csv { send_data @measurements.to_csv }
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @measurement.save
        format.html { redirect_to @measurement, notice: 'Measurement was successfully created' }
        format.json { render :show, status: :created, location: @measurement }
      else
        format.html { render :new, alert: 'Measurement could not be created' }
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
    authorize! :create, Measurement

    # secure the creation of new measurements
    if @profile.secure_data_entry
      unless @profile.data_entry_key == params[:key]
        return
      end
    end

    save_ok = false
    # If the save fails, include this error message in the response.
    create_err_msg = ""

    # some CHORDS users had an extra '0' on the beginnig of their instrument_id.
    # cleans this dirty input so that the create still works
    cleansed_instrument_id = params[:instrument_id].to_i

    if Instrument.exists?(id: cleansed_instrument_id)
      # Are the data submitted in this query a test?
      is_test_value = false

      if params.key?(:test)
        is_test_value = true
      end

      # Save the url that invoked us
      Instrument.update(cleansed_instrument_id, :last_url => request.original_url)

      # Create an array containing the names of legitimate variable names
      measured_at_parameters = Array.new
      variable_shortnames = Array.new

      Instrument.find(cleansed_instrument_id).vars.each do |var|
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
            measured_at = Time.now.iso8601
          end

          instrument = Instrument.find(cleansed_instrument_id)

          begin
            timestamp = ConvertIsoToMs.call(measured_at)
          rescue ArgumentError
            create_err_msg = "Time error."
          else
            value = params[var.shortname].to_f

            tags = influxdb_tags = instrument.influxdb_tags_hash
            tags[:site] = instrument.site_id
            tags[:inst] = instrument.id
            tags[:var]  = var.id
            tags[:test] = params.has_key?(:test)

            SaveTsPoint.call(timestamp, value, tags)
            save_ok = true
          end
        end
      end
    end

    respond_to do |format|
      if save_ok
        format.html { render text: 'Measurement created successfully' }
        format.json { render text: "OK" }
      else
        format.json { render text: "FAIL" }
        format.html { render text: "Measurement could not be created. " + create_err_msg, status: :bad_request }
      end
    end
  end

  def delete_test
    authorize! :destroy, Measurement

    if params.key?(:instrument_id)
      inst_id = params[:instrument_id]
      if Instrument.exists?(inst_id)
        DeleteTestTsPoints.call(TsPoint, inst_id)
      end
    end

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { head :no_content }
    end
  end

  def trim
    authorize! :destroy, Measurement

    notice_text = nil

    if params.key?(:end) and params.key?(:trim_id)
      trim_id = params[:trim_id]

      if trim_id == "all"
        Measurement.where("measured_at < ?", params[:end]).delete_all
        notice_text = 'Measurements before ' + params[:end] + ' were deleted for ALL instruments.'
      else
        if Instrument.exists?(trim_id)
          Measurement.where("measured_at < ? and instrument_id = ?", params[:end], params[:trim_id]).delete_all
          notice_text = 'Measurements before ' + params[:end] + ' were deleted for instrument ' + Instrument.find(trim_id).name
        end
      end
    end

    redirect_to data_path, notice: notice_text
  end

  def update
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

  def destroy
    if @measurement.destroy
      respond_to do |format|
        format.html { redirect_to measurements_url, notice: 'Measurement was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to measurements_url, notice: 'Measurement was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

private
  def measurement_params
    params.require(:measurement).permit(:instrument_id, :parameter, :value, :unit, :measured_at, :test, :end, :trim_id)
  end
end
