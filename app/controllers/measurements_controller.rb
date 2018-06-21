require 'time'

class MeasurementsController < ApplicationController
  # GET 'measurements/url_create?<many params>
  # Params:
  # test
  # instrument_id
  # shortname=val
  # at=iso8061
  # var_at=iso801
  def url_create
    save_ok = false
    auth = false

    # If the save fails, include this error message in the response.
    create_err_msg = ""

    # DEPRECATED: This needs to be removed down the road with just this left: authorize! :create, :measurement
    # secure the creation of new measurements
    if @profile.secure_data_entry
      if params[:api_key] && params[:email]
        authorize! :create, :measurement
        auth = true
      elsif params[:key] && @profile.data_entry_key == params[:key]
        auth = true
      end
    else
      auth = true
    end

    if !auth
      respond_to do |format|
        format.json { render json: 'FAIL: Not authorized to create measurements. Ensure secure key or api_key and email are present.', status: :unauthorized }
        format.html { render text: 'FAIL: Not authorized to create measurements. Ensure secure key or api_key and email are present.', status: :unauthorized }
      end
    end

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
      Instrument.update(cleansed_instrument_id,
                        last_url: InstrumentsHelper.sanitize_url(request.original_url.html_safe))

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
    authorize! :delete_test, :measurement

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

private
  def measurement_params
    params.require(:measurement).permit(:instrument_id, :parameter, :value, :unit, :measured_at, :test, :end, :trim_id)
  end
end
