class DropTsPointsSeries
  # Delete ALL measurements
  #
  # db      - the database.
  def self.call(db)

    # db.series returns a symbol. Convert to a string
    series = db.series.map {|x| x.to_s}[0]
      
    dropQuery = "drop series FROM \"#{series}\""
    queryresult = Influxer.client.query(dropQuery)

  end
end