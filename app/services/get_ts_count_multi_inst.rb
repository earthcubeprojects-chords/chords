class GetTsCountMultiInst
  # opts:
  #.      - find_test: [:either, :test, :not_test]
  #.      - start_time: DateTime or Time object
  #       - end_time: DateTime or Time object
  #
  # examples: GetTsCountMultiInst.call(TsPoint, [1,2,3])
  #           GetTsCountMultiInst.call(TsPoint, [1,2,3], find_test: :test)
  #           GetTsCountMultiInst.call(TsPoint, [1,2,3], find_test: :not_test)
  #           GetTsCountMultiInst.call(TsPoint, [1,2,3], start_time: Time.now - 1.day, end_time: Time.now)
  #           GetTsCountMultiInst.call(TsPoint, [1,2,3], start_time: Time.now - 1.day, end_time: Time.now, find_test: :not_test)
  def self.call(tsdb, inst_ids, opts={})
    counts = 0

    inst_ids = inst_ids.map(&:id) if inst_ids.is_a?(ActiveRecord::Relation)

    counts_query = tsdb.count('*').where(inst: inst_ids)

    if opts[:start_time]
      start_time = opts[:start_time]
      end_time = opts[:end_time]

      end_time = start_time if end_time.blank?
      start_time, end_time = end_time, start_time if start_time > end_time

      counts_query = counts_query.where(time: start_time..end_time)
    end

    case opts[:find_test]
    when :not_test
      counts_query = counts_query.where(test: false)
    when :test
      counts_query = counts_query.where(test: true)
    end

    if counts_query.length > 0
      counts = counts_query.to_a.first['count_value']
    end

    return counts
  end
end
