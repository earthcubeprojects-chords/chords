# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Profile.initialize
# Site.initialize
# Instrument.initialize

User.create(:email => "admin@chordsrt.com",    :password => "realtimedata", :is_administrator => 1)

# Using the ontology  http://sensorml.com/ont/swe/property
# (Recommended by Manil Maskey)
# another possibility is http://mmisw.org/ont/cf/parameter/
MeasuredProperty.populate
TopicCategory.populate
SiteType.populate

Archive.populate