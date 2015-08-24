class Profile < ActiveRecord::Base

  def self.initialize
    Profile.create([{
    project: 'Real-Time Measurements', 
    affiliation: 'My Organization',
    timezone: 'Mountain Time (US & Canada)',
    description: 'This is a CHORDS Portal.
    <ul>
    <li>A CHORDS Portal:</li>
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
    logo: nil}])      
  end
end
