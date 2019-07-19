class InfluxdbDiskUsed
  # Return the number of MB used by an InfluxDB database.
  # Return is a string
  def self.call()
    
    diskUsedQuery = "select sum(diskBytes) / 1024 /1024 from _internal.\"monitor\".\"shard\" where time > now() - 20s"
    queryresult = Influxer.client.query(diskUsedQuery) 

    if queryresult.length > 0
      total = queryresult[0]["values"][0]["sum"]
      return "#{'%.01f' % total}"
    end
    
    return "unknown"
  end
end
