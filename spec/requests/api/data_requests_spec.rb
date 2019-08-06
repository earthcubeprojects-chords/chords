# spec/requests/api/data_requests_spec.rb
require 'swagger_helper'
require 'rails_helper'
require 'json'

describe 'Data Download API', type: :request do
<<<<<<< HEAD

=======
>>>>>>> imaging_merge
  # initialize test data
  let!(:instruments) { create_list(:instrument, 2) }
  let(:configurator) { FactoryBot.create(:site_configurator) }
  let(:downloader) { FactoryBot.create(:data_downloader) }
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:creator) { FactoryBot.create(:data_creator) }

  describe 'GET /api/v1/data Unsecure Data Download' do
    before do
      profile = Profile.first || Profile.initialize.first
      profile.secure_data_download = false
      profile.secure_data_entry = false
      profile.save!
    end

    describe 'GET /api/v1/data#index' do
      it 'returns status code 200' do
        get '/api/v1/data'
        expect(response).to have_http_status(200)
      end

      it 'returns status code 200 with JSON' do
        get '/api/v1/data.json'
        expect(response).to have_http_status(200)
      end

      it 'returns status code 200 with GeoJSON' do
        get '/api/v1/data.geojson'
        expect(response).to have_http_status(200)
      end

      it 'returns status code 200 with CSV' do
        get '/api/v1/data.csv'
        expect(response).to have_http_status(200)
      end

      it 'returns status code 406 with HTML' do
        get '/api/v1/data.html'
        expect(response).to have_http_status(406)
      end
    end

    describe 'GET /api/v1/data#show' do
      let(:instrument) { Instrument.first }
      let(:var) { Var.first || FactoryBot.create(:var, instrument: instrument) }
      let(:profile) { Profile.first }

      it 'returns status code 200' do
        get "/api/v1/data/#{instrument.id}"
        expect(response).to have_http_status(200)
      end

      it 'returns status code 200 with JSON' do
        get "/api/v1/data/#{instrument.id}.json"
        expect(response).to have_http_status(200)
      end

      it 'returns status code 200 with GeoJSON' do
        get "/api/v1/data/#{instrument.id}.geojson"
        expect(response).to have_http_status(200)
      end

      it 'returns status code 200 with CSV' do
        get "/api/v1/data/#{instrument.id}.csv"
        expect(response).to have_http_status(200)
      end

      it 'returns status code 406 with HTML' do
        get "/api/v1/data/#{instrument.id}.html"
        expect(response).to have_http_status(406)
      end

      it 'returns proper metadata' do
        pending 'Still unsure why the composable matchers are not working correctly'
        get "/api/v1/data/#{instrument.id}.geojson"

        expected = {
          features: a_collection_including(
            a_hash_including(
              geometry: a_hash_including(
              coordinates: a_collection_including(
                instrument.site.lat.to_f,
                instrument.site.lon.to_f,
                instrument.site.elevation.to_f
              ),
              type: "Point"
            ),
            properties: a_hash_including(
              affiliation: profile.affiliation,
              data: [],
              doi: profile.doi,
              doi_citation: "https://citation.crosscite.org/?doi=#{profile.doi}",
              instrument: instrument.name,
              instrument_id: instrument.id,
              project: profile.project,
              sensor_id: instrument.sensor_id,
              site: instrument.site.name,
              site_id: instrument.site.id,
              variables: a_collection_including(
                a_hash_including(
                  name: var.name,
                  shortname: var.shortname,
                  measured_property: var.measured_property.try(:label),
                  measured_property_definition: var.measured_property.try(:definition),
                  measured_property_source: var.measured_property.try(:source),
                  measured_property_url: var.measured_property.try(:url),
                  units_name: var.unit.try(:name),
                  units_abbreviation: var.unit.try(:abbreviation),
                  units_type: var.unit.try(:type),
                  units_source: var.unit.try(:source),
                )
              )
            ),
            type: "Feature"
          )),
          type: "FeatureCollection"
        }

        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to include(expected)
      end
    end
  end

  describe 'GET /api/v1/data Secure Data Download' do
    before do
      profile = Profile.first || Profile.initialize.first
      profile.secure_data_download = true
      profile.save!
    end

    describe 'Download as Not Logged In / Guest' do
      describe 'Get /api/v1/data#index' do
        before do
          get '/api/v1/data.geojson'
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      describe 'Get /api/v1/data#show' do
        let(:instrument) { Instrument.first }

        before do
          get "/api/v1/data/#{instrument.id}.geojson"
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end
    end

    describe 'Download as User' do
      before do
        sign_in user
      end

      describe 'Get /api/v1/data#index' do
        before do
          get '/api/v1/data.geojson'
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      describe 'Get /api/v1/data#show' do
        let(:instrument) { Instrument.first }

        before do
          get "/api/v1/data/#{instrument.id}.geojson"
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end
    end

    describe 'Download as Downloader' do
      before do
        sign_in downloader
      end

      describe 'Get /api/v1/data#index' do
        before do
          get '/api/v1/data.geojson'
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      describe 'Get /api/v1/data#show' do
        let(:instrument) { Instrument.first }

        before do
          get "/api/v1/data/#{instrument.id}.geojson"
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'Download as Site Configurator' do
      before do
        sign_in configurator
      end

      describe 'Get /api/v1/data#index' do
        before do
          get '/api/v1/data.geojson'
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      describe 'Get /api/v1/data#show' do
        let(:instrument) { Instrument.first }

        before do
          get "/api/v1/data/#{instrument.id}.geojson"
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
    end

    describe 'Download as Admin' do
      before do
        sign_in admin
      end

      describe 'Get /api/v1/data#index' do
        before do
          get '/api/v1/data.geojson'
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      describe 'Get /api/v1/data#show' do
        let(:instrument) { Instrument.first }

        before do
          get "/api/v1/data/#{instrument.id}.geojson"
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
