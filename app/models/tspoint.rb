class TsPoint < Influxer::Metrics
  
  set_series :tsdata
  tags :site, :inst, :var, :test
  attributes :value

end