class DeleteTestTsPoints
  # Delete all of the points marked as "test" for the given instrument
  #
  # db      - the database.
  # inst_id - the instrument id
  def self.call(db, inst_id)
    
    dropQuery = "drop series FROM \"tsdata\" WHERE inst=\'#{inst_id}\' AND test=\'true\'"
    queryresult = Influxer.client.query(dropQuery) 

  end
end