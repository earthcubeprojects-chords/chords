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

    @errors = ActiveModel::Errors.new(self)

    # Is the user authorized to add measuments
    auth = false

    # users_json = params[:data].select {|element| element["type"] == "users" }



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

    
    is_test = params.key?(:test) && (params[:test] == true)

    if (request.content_type == 'application/vnd.api+json')

      json = {'instruments' => Array.new}


      data_json = JSON.parse(request.body.read)
      

      json_api_instruments = data_json['data'].select {|element| element["type"] == "instruments" }

      json_api_instruments.each do |json_api_instrument|


        instrument_id = json_api_instrument.dig('id') || nil
        sensor_id = json_api_instrument.dig('attributes', 'sensor_id') || nil

        instrument_json = {
          'instrument_id' => instrument_id,
          'sensor_id' => sensor_id,
          'variables' => []
        }


        json_api_vars = json_api_instrument.dig('attributes', 'vars') || nil

        json_api_vars.each do |json_api_var|

          shortname = json_api_var.dig('shortname') || nil

          var_json = {
            'shortname' => shortname,
            'measurements' => []
          }


          json_api_measurements = json_api_var.dig('measurements') || nil

          json_api_measurements.each do |json_api_measurement|
            value = json_api_measurement.dig('value') || nil
            at = json_api_measurement.dig('at') || nil

            measurement_json = {
              'value' => value,
              'measured_at' => at
            }

            var_json['measurements'].push(measurement_json)
          end

          instrument_json['variables'].push(var_json)
        end

        json['instruments'].push(instrument_json)
      end


      # Rails.logger.debug "json #{json}"
      # Rails.logger.debug "*" * 80
    else
      json = JSON.parse(request.body.read)
    end
    


    measurements = Array.new

    # The number of measurements that were added for each instrument
    measurements_added = Hash.new


    json['instruments'].each do |instrument_json|

      # instrument = Instrument.find(instrument_json['instrument_id'])


      # sensor_id may be used to find an instrument easier for embedded devices, prefer this over an instrument_id
      # will return nil if the instrument is not found
      instrument = if (instrument_json['sensor_id'])
                     Instrument.where(sensor_id: instrument_json['sensor_id']).first
                   else
                     Instrument.where(id: instrument_json['instrument_id'].to_i).first
                   end


      if (! instrument)
        render json: {errors: ["FAIL: Specified instrument could not be found. (sensor_id: #{instrument_json['sensor_id']}, instrument_id: #{instrument_json['instrument_id']})"]}, status: :unprocessable_entity 

        return
      end

      measurements_added[instrument.id] = 0

      if instrument
        # Save the url that invoked us
        instrument.update_attributes!(last_url: InstrumentsHelper.sanitize_url(request.original_url.html_safe))

        instrument_json['variables'].each do |variable_json|
          shortname = variable_json['shortname']
          variable_json['measurements'].each do |measurement_json|

            measurement = Measurement.new(instrument, shortname, measurement_json, is_test)
            measurement.validate!

            measurements.push(measurement)

            measurements_added[instrument.id] += 1

            # Check to see if there were validation errors when defining this measurement
            if measurement.errors.empty?
              # SaveTsPoint.call(measurement.timestamp, measurement.value, measurement.tags)
            else
              @errors.merge!(measurement.errors)
            end        

          end
        end
      end
    end


    if @errors.empty?

      # Save the entries in one bulk post
      SaveTsPoints.call(measurements)

      # update the measurement count
      measurements_added.each do |instrument_id, count|

        instrument = Instrument.find(instrument_id)

        if is_test
          instrument.update_attributes!(measurement_test_count: instrument.measurement_test_count + count)
        else
          instrument.update_attributes!(measurement_count: instrument.measurement_count + count)
        end
      end

      # Return success / 200
      render json: {errors: [], success: true, messages: ['OK']}, status: :ok 
    else
      # http://billpatrianakos.me/blog/2013/10/13/list-of-rails-status-code-symbols/
      error_msg = 'Measurements could not be created. ' 

      render json: {errors: @errors, success: false, messages: [error_msg]}, status: :unprocessable_entity
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
