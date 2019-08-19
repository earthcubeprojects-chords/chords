require 'rails_helper'
require 'json'



describe 'User ability specs', type: :request do
  let!(:instruments) { create_list(:instrument, 2) }
  let(:instrument) { Instrument.first }
  let(:var) { Var.first || FactoryBot.create(:var, instrument: instrument) }

  let(:creator) { FactoryBot.create(:data_creator) }
  

  describe 'Post Bulk Upload in Rails JSON format' do
    before do
      profile = Profile.first || Profile.initialize.first
      profile.secure_data_download = true
      profile.secure_data_viewing = true
      profile.save!
    end



    describe 'POST /measurements/bulk_create' do

      before do
        sign_in creator
        json = { :application => { :name => "foo", :description => "bar" } }
      end


      it 'returns status code 200 with JSON' do

        data = 
          {
             "email": creator.email,
             "api_key": creator.api_key,
             "test":true,
             "data": {
                "instruments": [
                   {
                      "instrument_id": instrument.id,
                      "measurements": [
                         {
                            "variable": var.shortname,
                            "measured_at": "2019-08-13T07:17:13.170Z",
                            "value": 2.2323
                         }
                      ]
                   }
                ]
             }
          }        

        # Rails 5 example:
        # from https://stackoverflow.com/questions/14775998/posting-raw-json-data-with-rails-3-2-11-and-rspec
        post "/measurements/bulk_create", params: data.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

        expect(response.header['Content-Type']).to include 'application/json'
        expect(response).to have_http_status(200)
      end
    end
  end


end
