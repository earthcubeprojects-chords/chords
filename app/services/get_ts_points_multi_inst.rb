class GetTsPointsMultiInst
  # Return the time series points within the specified time interval for multiple instruments.
  # An array of points will be returned.
  #
  # time_series_db - the database
  # inst_ids       - array instrument ids or an ActiveRecord::Relation of Instruments
  # start_time     - beginning time stamp...times greater or equal will be returned
  # end_time       - the end time...times less than this will be returned
  # find_test      - [:either, :not_test, :test]...returns both test and non-test data, only non-test data, or only test data
  #
  # examples:
  #            GetTsPointsMultiInst.call(TsPoint, [1,2,3], start_time: Time.new(2018,5), end_time: Time.now, find_test: :not_test)
  def self.call(time_series_db, inst_ids, opts={})
    inst_ids = inst_ids.map(&:id) if inst_ids.is_a?(ActiveRecord::Relation)

    ts_points = time_series_db.where(inst: inst_ids)

    if opts[:start_time]
      start_time = opts[:start_time]
      end_time = opts[:end_time]

      end_time = start_time if end_time.blank?
      start_time, end_time = end_time, start_time if start_time > end_time

      ts_points = ts_points.where(time: start_time..end_time)
    end

    case opts[:find_test]
    when :not_test
      ts_points = ts_points.where(test: false)
    when :test
      ts_points = ts_points.where(test: true)
    end

    return ts_points.to_a
  end
end
