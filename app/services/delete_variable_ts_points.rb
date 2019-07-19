class DeleteVariableTsPoints
  # Delete all InfluxDB data relted to a  specific variable
  #
  # time_series_db - the database.
  # var          - the variable object
  def self.call(db, var)
    
    # db.series returns a symbol. Convert to a string
    series = db.series.map {|x| x.to_s}[0]
      
    dropQuery = "drop series FROM \"#{series}\" WHERE var=\'#{var.id}\'"
    queryresult = Influxer.client.query(dropQuery)

  end
end