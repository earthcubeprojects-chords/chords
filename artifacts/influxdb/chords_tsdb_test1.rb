#!/usr/bin/env ruby

require_relative 'TSDBClient'
require 'json'

db = TSDBClient.new(database: 'chords', host: ARGV[0])
  
q_result = db.query 'select last("value") from tsdata'
last_time = q_result[0]["values"][0]["time"]
print 'Last data timestamp is ', last_time, "\n"

q = 'select count("value") from tsdata'
q_result = db.query q
print 'Total number of values is ', q_result[0]["values"][0]["count"], "\n"

# Count values by hour for each site
q = "select count(\"value\") from \"tsdata\" where time >= '#{last_time}' - 24h and time <= '#{last_time}' group by time(1h),\"site_id\""
value_counts_by_hour = db.query(q)

value_counts_by_hour.each do |site|
  # Print the counts
  site_id = site["tags"]["site_id"]
  print "site ", site_id, "\n"
  count_values = site["values"]
  count_values.each do |v|
    print "  ", v["time"], "  ", v["count"], "\n"
  end
  
  q = "select last(\"value\") from \"tsdata\" where \"site_id\" = '#{site_id}' group by \"instrument\""
  last_values = db.query q
  last_values.each do |last_value|
    # Print last value for each instrument
    i = last_value["tags"]["instrument"]
    t = last_value["values"][0]["time"]
    v = last_value["values"][0]["last"]
    print "     instrument ", i, " ", t, "  ", v, "\n"
  end
  
end
  
# To print nicely formatted JSON:
#puts JSON.pretty_generate(res)
