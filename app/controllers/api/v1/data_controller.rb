module API
  module V1
    class DataController < ApplicationController
      respond_to :json

      def index
        auth = false
        instruments = nil

        if ['json', 'geojson'].include?(params[:format])
          if @profile.secure_data_download
            authorize! :download, Instrument
            auth = true
          else
            auth = true
          end
        else
          render json: {errors: ['FAIL: Invalid format requested. JSON and GEOJSON are supported.']}, status: :not_acceptable
          return
        end

        if !auth
          render json: {errors: ['FAIL: Not authorized to create measurements. Ensure secure key or api_key and email are present.']}, status: :unauthorized
          return
        end

        instruments = Instrument.accessible_by(current_ability)

        instruments = if params[:sensors]
                        instruments.where(sensor_id: params[:sensors].split(','))
                      elsif params[:instruments]
                        instruments.where(id: params[:instruments].split(',').map(&:to_i))
                      else
                        instruments
                      end

        # Determine the time range. Default to the most recent day
        end_time = Time.now
        start_time = end_time - 1.day

        if params[:start]
          start_time = Time.parse(params[:start])
        end

        if params[:end]
          end_time = Time.parse(params[:end])
        end

        # Check whether to include test data
        test_opts = params.has_key?(:test) ? :test : :not_test

        # Check number of points to download against max allowed
        points_count = GetTsCountMultiInst.call(TsPoint, instruments, start_time: start_time, end_time: end_time, find_test: test_opts)
        allowed_points_count = Profile.first.max_download_points

        if points_count > allowed_points_count
          render json: {errors: ["FAIL: Requested number of data points exceeds that allowed. Requested: #{points_count}  Allowed: #{allowed_points_count}"]}, status: 413
          return
        end

        # Get the time series points from the database
        ts_points  = GetTsPointsMultiInst.call(TsPoint, instruments, start_time: start_time, end_time: end_time, find_test: test_opts)

        # File name root
        file_root = "#{@profile.project}_multi_instrument_download"
        file_root = file_root.split.join

        respond_to do |format|
          format.json do
            render json: MakeGeoJsonFromTsPoints.call(ts_points, @profile, instruments)
          end

          format.geojson do
            ts_json = MakeGeoJsonFromTsPoints.call(ts_points, @profile, instruments)
            send_data ts_json, filename: file_root + '.geojson'
          end
        end
      end

      def show
        auth = false

        @instrument = Instrument.accessible_by(current_ability).where(id: params[:id]).first

        if ['csv', 'json', 'geojson', 'sensorml'].include?(params[:format])
          if @profile.secure_data_download
            authorize! :download, @instrument
            auth = true
          else
            auth = true
          end
        else
          render json: {errors: ['FAIL: Invalid format requested. CSV, JSON, and GEOJSON are supported.']}, status: :not_acceptable
          return
        end

        if !auth
          render json: {errors: ['FAIL: Not authorized to create measurements. Ensure secure key or api_key and email are present.']}, status: :unauthorized
          return
        end

        # Get the timezone name and offset in minutes from UTC.
        @tz_name, @tz_offset_mins = ProfileHelper::tz_name_and_tz_offset

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

        # Check whether to include test data
        test_opts = params[:test] ? :test : :not_test

        # Check number of points to download against max allowed
        points_count = GetTsCountMultiInst.call(TsPoint, [@instrument.id], start_time: start_time, end_time: end_time, find_test: test_opts)
        allowed_points_count = Profile.first.max_download_points

        if points_count > allowed_points_count
          render json: {errors: ["FAIL: Requested number of data points exceeds that allowed. Requested: #{points_count}  Allowed: #{allowed_points_count}"]}, status: 413
          return
        end

        # Get the time series points from the database
        ts_points  = GetTsPointsMultiInst.call(TsPoint, [@instrument.id], start_time: start_time, end_time: end_time, find_test: test_opts)

        # File name root
        file_root = "#{@profile.project}_#{@instrument.site.name}_#{@instrument.name}"
        file_root = file_root.split.join

        respond_to do |format|
          format.csv do
            varnames_by_id = {}
            Var.all.where("instrument_id = #{@instrument.id}").each {|v| varnames_by_id[v[:id]] = v[:name]}
            ts_csv = MakeGeoCsvFromTsPoints.call(ts_points, Array.new, varnames_by_id, @instrument, request.host, Profile.first)
            send_data ts_csv, filename: file_root + '.csv'
          end

          format.json do
            render json: MakeGeoJsonFromTsPoints.call(ts_points, @profile, @instrument)
          end

          format.geojson do
            ts_json = MakeGeoJsonFromTsPoints.call(ts_points, @profile, @instrument)
            send_data ts_json, filename: file_root + '.geojson'
          end
        end
      end

    private
      def data_params
        params.require(:data).permit(:instruments, :start, :end)
      end
    end
  end
end
