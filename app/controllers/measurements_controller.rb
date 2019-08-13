require 'time'

class MeasurementsController < ApplicationController


  # GET 'measurements/bulk_create?<many params>
  # Params:
  # test
  # instrument_id
  # sensor_id
  # shortname=val
  # at=iso8061
  def bulk_create
    Rails.logger.debug "*" * 80
    Rails.logger.debug(request.body.inspect)
    Rails.logger.debug "email: #{params['email']}" 
    Rails.logger.debug "api_key: #{params['api_key']}" 
    Rails.logger.debug "*" * 80


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
      render json: {errors: ['FAIL: Not authorized to create measurements. Ensure secure key or api_key and email are present.']}, status: :unauthorized 

      return
    end






    if save_ok
      render json: {errors: [], success: true, messages: ['OK']}, status: :ok 
    else
      error_msg = 'Measurement could not be created. ' + create_err_msg
      render json: {errors: [error_msg], success: false, messages: []}, status: :bad_request 
    end
  end


  # GET 'measurements/url_create?<many params>
  # Params:
  # test
  # instrument_id
  # sensor_id
  # shortname=val
  # at=iso8061
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
        format.json { render json: {errors: ['FAIL: Not authorized to create measurements. Ensure secure key or api_key and email are present.']}, status: :unauthorized }
        format.html { render plain: 'FAIL: Not authorized to create measurements. Ensure secure key or api_key and email are present.', status: :unauthorized }
      end

      return
    end


    # sensor_id may be used to find an instrument easier for embedded devices, prefer this over an instrument_id
    # will return nil if the instrument is not found
    instrument = if params[:sensor_id]
                   Instrument.where(sensor_id: params[:sensor_id]).first
                 else
                   Instrument.where(id: params[:instrument_id].to_i).first
                 end

    if instrument
      # Save the url that invoked us
      instrument.update_attributes!(last_url: InstrumentsHelper.sanitize_url(request.original_url.html_safe))

      measured_at = if params[:at]
                      params[:at]
                    else
                      Time.now.iso8601
                    end

      timestamp = begin
                    ConvertIsoToMs.call(measured_at)
                  rescue ArgumentError, e
                    create_err_msg = "Time format error, please ensure time is formatted using ISO8601."
                    nil
                  end

      if timestamp
        var_count = 0
        is_test_value = params.key?(:test)

        tags = instrument.influxdb_tags_hash
        tags[:site] = instrument.site_id
        tags[:inst] = instrument.id
        tags[:test] = is_test_value

        instrument.vars.each do |var|
          if params[var.shortname]
            value = params[var.shortname].to_f
            tags[:var]  = var.id

            SaveTsPoint.call(timestamp, value, tags)
            save_ok = true
            var_count += 1
          end
        end

        if var_count > 0
          if is_test_value
            instrument.update_attributes!(measurement_test_count: instrument.measurement_test_count + var_count)
          else
            instrument.update_attributes!(measurement_count: instrument.measurement_count + var_count)
          end
        end
      end
    end

    respond_to do |format|
      if save_ok
        format.html { render plain: 'Measurement created successfully', status: :ok }
        format.json { render json: {errors: [], success: true, messages: ['OK']}, status: :ok }
      else
        error_msg = 'Measurement could not be created. ' + create_err_msg
        format.json { render json: {errors: [error_msg], success: false, messages: []}, status: :bad_request }
        format.html { render plain: error_msg, status: :bad_request }
      end
    end
  end

  def delete_test
    authorize! :delete_test, :measurement

    if params.key?(:instrument_id)
      inst_id = params[:instrument_id]

      if Instrument.exists?(inst_id)
        DeleteTestTsPoints.call(TsPoint, inst_id)

        inst = Instrument.find(inst_id)
        inst.update_attributes!(measurement_test_count: 0)
      end
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: instruments_path }
      format.json { head :no_content }
    end
  end

private
  def measurement_params
    params.require(:measurement).permit(:instrument_id, :sensor_id, :parameter, :value, :unit, :measured_at, :test,
                                        :end, :trim_id, :at)
  end
end
