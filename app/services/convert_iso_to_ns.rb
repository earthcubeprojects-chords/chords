class ConvertIsoToNs
  def self.call(time_string)
    ns = ((Time.iso8601(time_string).to_f) * 1000000000).to_i
    return ns
  end
end
