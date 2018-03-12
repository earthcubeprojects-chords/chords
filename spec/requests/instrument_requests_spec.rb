require "rails_helper"

RSpec.describe "Instrument data requests", type: :request do
  it "returns sensorml" do
    get "/instruments/1.sensorml"
    byebug
    expect(response).to have_http_status(:ok)
  end
end
