class Profile < ActiveRecord::Base

  def self.initialize
    Profile.create([{project: 'PECAN', affiliation: 'NCAR', description: 'The Plains Elevated Convection at Night (PECAN) campaign is aiming to increase the understanding of the conditions that lead to thunderstorm initiation and that control the lifecycle of large-scale thunderstorm systems (known as Mesoscale Convective Systems or MCSs) at night over the continental United States. <p>PECAN involves eight research laboratories and 14 universities, both national and international. PECAN will be conducted across northern Oklahoma, central Kansas and into south-central Nebraska from 1 June to 15 July 2015, and is funded by the NSF, NOAA, NASA, and the U.S. DOE.', logo: ''}])      
  end
end
