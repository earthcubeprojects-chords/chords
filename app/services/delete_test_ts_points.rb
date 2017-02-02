class DeleteTestTsPoints
  # Delete all of the points marked as "test" for the given instrument
  #
  # db      - the database.
  # inst_id - the instrument id
  def self.call(db, inst_id)

    # db.series returns a symbol. Convert to a string
    series = db.series.map {|x| x.to_s}[0]
      
    dropQuery = "drop series FROM \"#{series}\" WHERE inst=\'#{inst_id}\' AND test=\'true\'"
    queryresult = Influxer.client.query(dropQuery)

  end
end