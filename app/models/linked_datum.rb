class LinkedDatum < ApplicationRecord
  validates :doi, allow_blank: true, format: {with: /\A(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)/, message: "invalid DOI"}

  def self.initialize(default_host=nil)
    profile = Profile.first

    LinkedDatum.create({
      name: profile.project,
      description: profile.project,
      keywords: 'realtime, data',
      dataset_url: default_host
    })
  end

  def organization
    {
      "@context": "http://schema.org",
      "@type": "Organization",
      "url": dataset_url,
      "logo": dataset_url[0..-2] + ActionController::Base.helpers.image_url("CHORDS_logo_144.png")
    }.to_json
  end

  def to_json_ld
    data = {}

    context = {
      '@vocab': 'http://schema.org',
      'datacite': 'http://purl.org/spar/datacite/',
      'earthcollab': 'https://library.ucar.edu/earthcollab/schema#',
      'geolink': 'http://schema.geolink.org/1.0/base/main#',
      'vivo': 'http://vivoweb.org/ontology/core#',
      'dbpedia': 'http://dbpedia.org/resource/',
      'geo-upper': 'http://www.geoscienceontology.org/geo-upper#'
    }

    type = 'Dataset'

    additional_type = [
      'http://schema.geolink.org/1.0/base/main#Dataset',
      'http://vivoweb.org/ontology/core#Dataset'
    ]

    data_name = self.name
    version = 'realtime'

    identifier =  if !doi.blank?
                    {
                      '@id': "https://data.datacite.org/#{doi}",
                      '@type': 'PropertyValue',
                      'additionalType': [
                        'http://schema.geolink.org/1.0/base/main#Identifier',
                        'http://purl.org/spar/datacite/Identifier'
                      ],
                      'propertyID': 'http://purl.org/spar/datacite/doi',
                      'url': "https://doi.org/#{doi}",
                      'value': doi
                    }
                  else
                    nil
                  end

    variable_measured = [
      {
        '@id': dataset_url,
        '@type': "PropertyValue",
        'additionalType': 'https://library.ucar.edu/earthcollab/schema#Parameter',
        'value': 'experiment',
        'description': data_name
      }
    ]

    spatial_coverage = {'@type': 'Place', 'geo': []}

    Site.all.each do |site|
      spatial_coverage[:geo] << {
        '@type': 'GeoCoordinates',
        'latitude': site.lat,
        'longitude': site.lon
      }
    end

    data['@context'] = context
    data['@type'] = type
    data['additionalType'] = additional_type
    data['name'] = data_name
    data['description'] = description
    data['url'] = dataset_url
    data['version'] = version
    data['keywords'] = keywords
    data['spatialCoverage'] = spatial_coverage
    data['variableMeasured'] = variable_measured
    data['license'] = license unless license.blank?
    data['identifier'] = identifier unless identifier.blank?

    data.to_json
  end
end
