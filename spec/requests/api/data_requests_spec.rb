require 'rails_helper'

describe 'Data Download API', type: :request do
  # initialize test data
  let!(:instruments) { create_list(:instrument, 2) }
  let(:configurator) { FactoryBot.create(:site_configurator) }
  let(:downloader) { FactoryBot.create(:data_downloader) }
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }

  describe 'GET /api/v1/data Unsecure Data Download' do
    before do
      profile = Profile.first || Profile.initialize.first
      profile.secure_data_download = false
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
