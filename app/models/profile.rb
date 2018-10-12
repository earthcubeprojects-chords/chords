class Profile < ApplicationRecord
  require 'task_helpers/cuahsi_helper'
  include CuahsiHelper


  validates :doi, allow_blank: true, format: {
    with:    /10.\d{4,9}\/[-._;()\/:A-Z0-9]+/i,
    message: "invalid DOI"
  }

  validates :domain_name, format: {
     with: /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z0-9]{1,5}(:[0-9]{1,5})?(\/.*)?$/ix,
     multiline: true,
     message: "The domain name is not in a valid format. (Expecting subdomain.domain.com format. Do not include http/https.)"
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

  def get_cuahsi_sources
    uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/GetSourcesJSON"
    return JSON.parse(CuahsiHelper::send_request(uri_path, "").body)

  end

  def get_cuahsi_sourceid(url)
    if self.cuahsi_source_id
      return self.cuahsi_source_id
    else
      sources = get_cuahsi_sources
      id = sources.find {|source| source['SourceLink']==url}
      if id != nil
        self.cuahsi_source_id = id["SourceID"]
        self.save
        return self.cuahsi_source_id
      end
      return id
    end
  end

  def push_cuahsi_sources
    Profile.all.each do |profile|
      data = profile.create_cuahsi_source
      if profile.get_cuahsi_sourceid(data["link"]).nil?
        uri_path = Rails.application.config.x.archive['base_url'] + "/default/services/api/sources"
        CuahsiHelper::send_request(uri_path, data)
        profile.get_cuahsi_sourceid(data["link"])
      end
    end
  end

  def create_cuahsi_source
    citation = self.doi
    if citation.nil? || citation.empty?
        citation = self.project
    end
    data = {
        "user" => Rails.application.config.x.archive['username'],
        "password" => Rails.application.config.x.archive['password'],
        "organization" => self.affiliation,
        "description" => self.project,
        "link" => self.domain_name,
        "name" => self.contact_name,
        "phone" =>self.contact_phone,
        "email" =>self.contact_email,
        "address" => self.contact_address,
        "city" => self.contact_city,
        "state" => self.contact_state,
        "zipcode" => self.contact_zipcode,
        "citation" => citation,
        "metadata" => 1
        }
    return data
  end
end
