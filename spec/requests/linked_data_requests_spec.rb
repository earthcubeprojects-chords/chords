require 'rails_helper'

describe 'about page requests', type: :request do
  it 'returns 200 when no linked data exist' do
    profile = Profile.first || Profile.initialize.first
    profile.save!

    expect(LinkedDatum.first).to be_nil

    get about_index_path
    expect(response).to have_http_status(:ok)
    expect(response).not_to render_template('about/_json_ld_dataset')
    expect(response.body).not_to include 'application/ld+json'
  end

  it 'returns 200 when linked data do exist' do
    profile = Profile.first || Profile.initialize.first
    profile.save!

    ld = FactoryBot.create(:linked_datum)

    expect(LinkedDatum.first).not_to be_nil

    get about_index_path
    expect(response).to have_http_status(:ok)
    expect(response).to render_template('about/_json_ld_dataset')
  end
end
