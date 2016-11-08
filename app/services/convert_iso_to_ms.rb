class ConvertIsoToMs
  def self.call(time_string)
    ms = ((Time.iso8601(time_string).to_f) * 1000.0).to_i
    return ms
  end
end
