class Profile < ApplicationRecord
  validates :doi, allow_blank: true, format: {
    with:    /10.\d{4,9}\/[-._;()\/:A-Z0-9]+/i,
    message: "invalid DOI"
  }

  validates :domain_name, format: {
     with: /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z0-9]{1,5}(:[0-9]{1,5})?(\/.*)?$/ix,
     multiline: true,
     message: "The domain name is not in a valid format. (Expecting subdomain.domain.com format. Do not include http/https.)"
  }

  validates :data_archive_url, allow_blank: true, format: {
     with: /^http(s)?\:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z0-9]{1,5}(:[0-9]{1,5})?(\/.*)?$/ix,
     multiline: true,
     message: "The data archive url is not in a valid format. (Expecting subdomain.domain.com format. Include http/https.)"
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
    secure_data_download: true,
    secure_data_viewing: false,
    secure_data_entry: true,
    data_entry_key: 'key',
    doi: '10.5065/d6v1236q'

    }])
  end
end
