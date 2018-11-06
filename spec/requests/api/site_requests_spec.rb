require 'rails_helper'

describe 'Sites API', type: :request do
  # initialize test data
  let!(:sites) { create_list(:site, 10) }
  let(:site_id) { sites.first.id }
  let(:site) { sites.first }
  let(:user) { FactoryBot.create(:site_configurator) }

  # index
  describe 'GET /api/v1/sites Authenticated' do
    before do
      sign_in user
      get '/api/v1/sites'
    end

    it 'returns sites' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /api/v1/sites Unauthenticated' do
    before do
      get '/api/v1/sites'
    end

    it 'does not return sites' do
      expect(json).not_to be_empty
      expect(json).to have_key 'errors'
      expect(json['errors']).not_to be_empty
      expect(json['errors'].first).to include('Access Denied')
    end

    it 'returns status code 403' do
      expect(response).to have_http_status(403)
    end
  end

  # show
  describe 'GET /api/v1/sites/[:id] Authenticated' do
    before do
      sign_in user
      get "/api/v1/sites/#{site_id}"
    end

    it 'returns first site' do
      expect(json).not_to be_empty
      expect(json).not_to have_key 'errors'

      expect(json['name']).to eq site.name
      expect(json['lat'].try(:to_f)).to eq site.lat
      expect(json['lon'].try(:to_f)).to eq site.lon
      expect(json['elevation'].try(:to_f)).to eq site.elevation
      expect(json['description']).to eq site.description
      expect(json['site_type_id']).to eq site.site_type_id
      expect(json['cuahsi_site_code']).to eq site.cuahsi_site_code
      expect(json['cuahsi_site_id']).to eq site.cuahsi_site_id
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

    describe 'GET /api/v1/sites/[:id] Unauthenticated' do
    before do
      get "/api/v1/sites/#{site_id}"
    end

    it 'does not return site' do
      expect(json).not_to be_empty
      expect(json).to have_key 'errors'
      expect(json['errors']).not_to be_empty
      expect(json['errors'].first).to include('Access Denied')
    end

    it 'returns status code 403' do
      expect(response).to have_http_status(403)
    end
  end
end
