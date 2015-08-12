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


User.create(:email => "mdye@ucar.edu", :password => "realtimedata")
User.create(:email => "martin@ucar.edu", :password => "realtimedata")

Site.create(id:7, name: 'Boulder ', lat: 40.029,lon: -105.337 )

Site.create(id:8, name: 'Boulder Sugarloaf', lat: 40.0293,lon: -105.397 )

Instrument.create(id: 21, name: 'Acurite Wx Station', site_id: 8, display_points: 100, seconds_before_timeout: 3)
Var.create(id:9, name: 'Tdry', shortname: 'v1', instrument_id: 21)
Var.create(id:10, name: 'RH', shortname: 'v2', instrument_id: 21)
Var.create(id:11, name: 'Wspd', shortname: 'v3', instrument_id: 21)
Var.create(id:12, name: 'Wdir', shortname: 'v4', instrument_id: 21)
Var.create(id:13, name: 'Pres', shortname: 'v5', instrument_id: 21)
Var.create(id:14, name: 'RainRate', shortname: 'v6', instrument_id: 21)
Var.create(id:15, name: 'RainTotal', shortname: 'v7', instrument_id: 21)
Var.create(id:16, name: 'DewPoint', shortname: 'v8', instrument_id: 21)


