require 'influxdb'
require 'json'

class TSDB

  def initialize(dbname, host)
    @db = InfluxDB::Client.new dbname, host: host
  end
  
  def query(q)
    return @db.query q
  end
  
  def write(site, name, time, value)
    db.query 
  end
end 

db = TSDB.new 'chords', 'influxdb'

# without a block:
res = db.query 'select count(*) from data group by "site_id", "name"'
puts res

#puts JSON.pretty_generate(res)

# results are grouped by name, but also their tags:
#
# [
#   {
#     "name"=>"time_series_1",
#     "tags"=>{"region"=>"uk"},
#     "values"=>[
#       {"time"=>"2015-07-09T09:03:31Z", "count"=>32, "value"=>0.9673},
#       {"time"=>"2015-07-09T09:03:49Z", "count"=>122, "value"=>0.4444}
#     ]
#   },
#   {
#     "name"=>"time_series_1",
#     "tags"=>{"region"=>"us"},
#     "values"=>[
#       {"time"=>"2015-07-09T09:02:54Z", "count"=>55, "value"=>0.4343}
#     ]
#   }
# ]

# with a block:
db.query 'select * from data' do |name, tags, points|
  puts "#{name} [ #{tags.inspect} ]"
  points.each do |pt|
    puts "  -> #{pt.inspect}"
  end
end
