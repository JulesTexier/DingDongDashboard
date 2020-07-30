require 'rails_helper'

RSpec.describe "Api::V1::SavedProperties", type: :request do

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/saved_properties/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/saved_properties/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
