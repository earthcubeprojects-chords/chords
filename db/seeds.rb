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


# Profile.create([{project: 'PECAN', affiliation: 'NCAR', description: 'The Plains Elevated Convection at Night (PECAN) campaign is aiming to increase the understanding of the conditions that lead to thunderstorm initiation and that control the lifecycle of large-scale thunderstorm systems (known as Mesoscale Convective Systems or MCSs) at night over the continental United States. <p>PECAN involves eight research laboratories and 14 universities, both national and international. PECAN will be conducted across northern Oklahoma, central Kansas and into south-central Nebraska from 1 June to 15 July 2015, and is funded by the NSF, NOAA, NASA, and the U.S. DOE.', logo: ''}])