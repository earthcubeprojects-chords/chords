require 'rails_helper'

describe 'Unauthenticated instrument data requests', type: :request do
  it 'returns 403 when unauthorized' do
    profile = Profile.first || Profile.initialize.first
    profile.save!

    instrument = FactoryBot.create(:instrument)

    get "/instruments/#{instrument.id}.sensorml"
    expect(response).to have_http_status(:forbidden)
  end

  it 'returns sensorml when auth not required' do
    profile = Profile.first || Profile.initialize.first
    profile.secure_data_viewing = false
    profile.secure_data_download = false
    profile.save!

    instrument = FactoryBot.create(:instrument)

    get "/instruments/#{instrument.id}.sensorml"
    expect(response).to have_http_status(:ok)
  end
end

describe 'Authenticated instrument data requests', type: :request do
  it 'returns 200 when authorized' do
    profile = Profile.first || Profile.initialize.first
    profile.save!

    user = FactoryBot.create(:data_downloader)
    instrument = FactoryBot.create(:instrument)

    sign_in user

    get "/instruments/#{instrument.id}.sensorml"
    expect(response).to have_http_status(:ok)
  end
end
