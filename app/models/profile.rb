class Profile < ActiveRecord::Base

  def self.initialize
    Profile.create([{
    project: 'EarthCube All Hands', 
    affiliation: 'NCAR',
    time_zone: 'Mountain Time (US & Canada)',
    description: 'This is a demonstration of the CHORDS Portal testbed, configured for the May 2015 NSF EarthCube All Hands Meeting.
    <br>
    We want to show that:
    <ul>
    <li>CHORDS Portal:</li>
    <ul>
    <li>is simple to create and configure.</li>
    <li>it\'s really easy to post data from sensors into the portal.</li>
    <li>it\'s really easy to get data from the portal into your diverse applications.</li>
    <li>the portal provides a simple but comprehensive view of your complete real-time data system.</li>
    </ul>
    <li>CHORDS Services:</li>
    <ul>
    <li>can connect easily to (many) portals.</li>
    <li>can leverage the real-time streams into other more sophisticated and standardized web services (such as mapping, data federation, and discovery).</li>
    </ul>
    </ul>
    
    ', 
    logo: ''}])      
  end
end
