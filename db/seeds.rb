# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


Site.create([{name: 'ISS1 Lyons', lat: '40.2', lon:'-104.0'}])
Site.create([{name: 'ISS2 Sugarloaf', lat: '40.0', lon:'-104.1'}])
Site.create([{name: 'ISS3 Nederland', lat: '39.9', lon:'-104.3'}])

Instrument.create([{name: 'Campbell', site_id:'1', }])
Instrument.create([{name: 'Campbell', site_id:'2', }])
Instrument.create([{name: 'Campbell', site_id:'3', }])

Instrument.create([{name: '449 Profiler', site_id:'2', }])

Instrument.create([{name: '915 Profiler', site_id:'1', }])
Instrument.create([{name: '915 Profiler', site_id:'3', }])
