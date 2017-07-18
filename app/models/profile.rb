class Profile < ActiveRecord::Base

    validates :doi, allow_blank: true, format: {
      with:    /10.\d{4,9}\/[-._;()\/:A-Z0-9]+/i,
      message: "invalid DOI"
    }

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
    logo: nil,
    secure_administration: true,
    data_entry_key: 'key'
    
    }])      
  end

  def self.create_cuahsi_source
    p = Profile.find(1)
    citation = p.doi
    if citation.nil? || citation.empty?
        citation = p.project
    end
    data = {
        "user" => 'chords',
        "password" => 'chords',
        "organization" => p.affiliation,
        "description" => p.project,
        "link" => 'example.com',
        "name" => p.contact_name,
        "phone" =>p.contact_phone,
        "email" =>p.contact_email,
        "address" => p.contact_address,
        "city" => p.contact_city,
        "state" => p.contact_state,
        "zipcode" => p.contact_zipcode,
        "citation" => citation,
        "metadata" => 1
        }
    return data
  end
end
