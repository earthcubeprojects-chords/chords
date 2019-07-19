require 'rails_helper'

describe 'User ability specs', type: :request do
  let!(:instruments) { create_list(:instrument, 2) }
  let!(:linked_datum) { FactoryBot.create(:linked_datum) }

  let(:user) { FactoryBot.create(:user) }
  let(:downloader) { FactoryBot.create(:data_downloader) }
  let(:measurements) { FactoryBot.create(:data_creator) }
  let(:configurator) { FactoryBot.create(:site_configurator) }
  let(:admin) { FactoryBot.create(:admin) }
  let(:mixed_user) { FactoryBot.create(:data_creator, roles: [:registered_user, :downloader, :measurements]) }
  let(:admin_api) { FactoryBot.create(:data_creator, roles: [:admin, :downloader]) }
  let(:configurator_api) { FactoryBot.create(:data_creator, roles: [:site_config, :downloader]) }

  describe 'Secure Download and Data Viewing requests' do
    before do
      profile = Profile.first || Profile.initialize.first
      profile.secure_data_download = true
      profile.secure_data_viewing = true
      profile.save!
    end

    describe 'Admin user' do
      before do
        sign_in admin
      end

      it 'can view about' do
        get '/about'
        expect(response).to have_http_status(200)
      end

      it 'can view dashboard' do
        get '/dashboard'
        expect(response).to have_http_status(200)
      end

      it 'can view data' do
        get '/data'
        expect(response).to have_http_status(200)
      end

      it 'can view influxdb_tags' do
        get '/influxdb_tags'
        expect(response).to have_http_status(200)
      end

      it 'can view linked_data' do
        get "/linked_data"
        expect(response).to have_http_status(200)
      end

      it 'can view measured properties' do
        get '/measured_properties'
        expect(response).to have_http_status(200)
      end

      it 'can view site types' do
        get '/site_types'
        expect(response).to have_http_status(200)
      end

      it 'can view topic categories' do
        get '/topic_categories'
        expect(response).to have_http_status(200)
      end

      it 'can view units' do
        get '/units'
        expect(response).to have_http_status(200)
      end

      it 'can view data urls' do
        get '/about/data_urls'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#index' do
        get '/instruments'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#show' do
        get "/instruments/#{instruments.first.id}"
        expect(response).to have_http_status(200)
      end

      it 'can view the profile' do
        get '/profiles'
        expect(response).to have_http_status(200)
      end

      it 'can view sites#index' do
        get '/sites'
        expect(response).to have_http_status(200)
      end

      it 'can view sites#show' do
        get "/sites/#{instruments.first.site.id}"
        expect(response).to have_http_status(200)
      end

      it 'can view site map' do
        get '/sites/map'
        expect(response).to have_http_status(200)
      end

      it 'can view users#index' do
        get '/users'
        expect(response).to have_http_status(200)
      end

      it 'can view users#show and has edit button' do
        get "/users/#{mixed_user.id}"
        expect(response).to have_http_status(200)
        expect(response.body).to include 'Edit User'
      end

      it 'can view vars' do
        get '/vars'
        expect(response).to have_http_status(200)
      end
    end

    describe 'Site Config user' do
      before do
        sign_in configurator
      end

      it 'can view about' do
        get '/about'
        expect(response).to have_http_status(200)
      end

      it 'can view dashboard' do
        get '/dashboard'
        expect(response).to have_http_status(200)
      end

      it 'can view data' do
        get '/data'
        expect(response).to have_http_status(200)
      end

      it 'can view influxdb_tags' do
        get '/influxdb_tags'
        expect(response).to have_http_status(200)
      end

      it 'can view linked_data' do
        get "/linked_data"
        expect(response).to have_http_status(200)
      end

      it 'can view measured properties' do
        get '/measured_properties'
        expect(response).to have_http_status(200)
      end

      it 'can view site types' do
        get '/site_types'
        expect(response).to have_http_status(200)
      end

      it 'can view topic categories' do
        get '/topic_categories'
        expect(response).to have_http_status(200)
      end

      it 'can view units' do
        get '/units'
        expect(response).to have_http_status(200)
      end

      it 'can view data urls' do
        get '/about/data_urls'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#index' do
        get '/instruments'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#show' do
        get "/instruments/#{instruments.first.id}"
        expect(response).to have_http_status(200)
      end

      it 'can view the profile' do
        get '/profiles'
        expect(response).to have_http_status(200)
      end

      it 'can view sites#index' do
        get '/sites'
        expect(response).to have_http_status(200)
      end

      it 'can view sites#show' do
        get "/sites/#{instruments.first.site.id}"
        expect(response).to have_http_status(200)
      end

      it 'can view site map' do
        get '/sites/map'
        expect(response).to have_http_status(200)
      end

      it 'can view users#index' do
        get '/users'
        expect(response).to have_http_status(200)
      end

      it 'can view users#show but not edit' do
        get "/users/#{mixed_user.id}"
        expect(response).to have_http_status(200)
        expect(response.body).not_to include 'Edit User'
      end

      it 'can view vars' do
        get '/vars'
        expect(response).to have_http_status(200)
      end
    end

    describe 'Registered User' do
      before do
        sign_in user
      end

      it 'can view about' do
        get '/about'
        expect(response).to have_http_status(200)
      end

      it 'can view dashboard' do
        get '/dashboard'
        expect(response).to have_http_status(200)
      end

      it 'cannot view data' do
        get '/data'
        expect(response).to have_http_status(302)
      end

      it 'can view influxdb_tags' do
        get '/influxdb_tags'
        expect(response).to have_http_status(200)
      end

      it 'cannot view linked data' do
        get "/linked_data"
        expect(response).to have_http_status(302)
      end

      it 'can view measured properties' do
        get '/measured_properties'
        expect(response).to have_http_status(200)
      end

      it 'can view site types' do
        get '/site_types'
        expect(response).to have_http_status(200)
      end

      it 'can view topic categories' do
        get '/topic_categories'
        expect(response).to have_http_status(200)
      end

      it 'can view units' do
        get '/units'
        expect(response).to have_http_status(200)
      end

      it 'can view data urls' do
        get '/about/data_urls'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#index' do
        get '/instruments'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#show' do
        get "/instruments/#{instruments.first.id}"
        expect(response).to have_http_status(200)
      end

      it 'cannot view the profile' do
        get '/profiles'
        expect(response).to have_http_status(302)
      end

      it 'can view sites#index' do
        get '/sites'
        expect(response).to have_http_status(200)
      end

      it 'can view sites#show' do
        get "/sites/#{instruments.first.site.id}"
        expect(response).to have_http_status(200)
      end

      it 'can view site map' do
        get '/sites/map'
        expect(response).to have_http_status(200)
      end

      it 'can view users#index' do
        get '/users'
        expect(response).to have_http_status(200)
        expect(response.body).not_to include "#{admin.email}"
      end

      it 'can view users#show for self' do
        get "/users/#{user.id}"
        expect(response).to have_http_status(200)
        expect(response.body).to include 'Edit User'
      end

      it 'cannot view users#show for others' do
        get "/users/#{mixed_user.id}"
        expect(response).to have_http_status(302)
      end

      it 'can view vars' do
        get '/vars'
        expect(response).to have_http_status(200)
      end
    end

    describe 'Mixed User' do
      before do
        sign_in mixed_user
      end

      it 'can view about' do
        get '/about'
        expect(response).to have_http_status(200)
      end

      it 'can view dashboard' do
        get '/dashboard'
        expect(response).to have_http_status(200)
      end

      it 'can view data' do
        get '/data'
        expect(response).to have_http_status(200)
      end

      it 'can view influxdb_tags' do
        get '/influxdb_tags'
        expect(response).to have_http_status(200)
      end

      it 'cannot view linked data' do
        get "/linked_data"
        expect(response).to have_http_status(302)
      end

      it 'can view measured properties' do
        get '/measured_properties'
        expect(response).to have_http_status(200)
      end

      it 'can view site types' do
        get '/site_types'
        expect(response).to have_http_status(200)
      end

      it 'can view topic categories' do
        get '/topic_categories'
        expect(response).to have_http_status(200)
      end

      it 'can view units' do
        get '/units'
        expect(response).to have_http_status(200)
      end

      it 'can view data urls' do
        get '/about/data_urls'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#index' do
        get '/instruments'
        expect(response).to have_http_status(200)
      end

      it 'can view instruments#show' do
        get "/instruments/#{instruments.first.id}"
        expect(response).to have_http_status(200)
      end

      it 'cannot view the profile' do
        get '/profiles'
        expect(response).to have_http_status(302)
      end

      it 'can view sites#index' do
        get '/sites'
        expect(response).to have_http_status(200)
      end

      it 'can view sites#show' do
        get "/sites/#{instruments.first.site.id}"
        expect(response).to have_http_status(200)
      end

      it 'can view site map' do
        get '/sites/map'
        expect(response).to have_http_status(200)
      end

      it 'can view users#index' do
        get '/users'
        expect(response).to have_http_status(200)
        expect(response.body).not_to include "#{user.email}"
      end

      it 'can view users#show for self' do
        get "/users/#{mixed_user.id}"
        expect(response).to have_http_status(200)
        expect(response.body).to include 'Edit User'
      end

      it 'cannot view users#show for others' do
        get "/users/#{user.id}"
        expect(response).to have_http_status(302)
      end

      it 'can view vars' do
        get '/vars'
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'Secure Download and Open Data Viewing requests' do

  end

  describe 'Open Download and Secure Data Viewing requests' do

  end

  describe 'Open Download and Data Viewing requests' do

  end

end
