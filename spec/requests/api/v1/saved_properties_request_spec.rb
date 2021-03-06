require 'rails_helper'

RSpec.describe "Api::V1::SavedProperties", type: :request do
  headers = { "AUTHORIZATION" => "Bearer DD-nFMdxvgGEXdpEs7whj" }

  describe "POST /create" do
    it "returns http success" do
      agglomeration = FactoryBot.create(:agglomeration)
      research = FactoryBot.create(:subscriber_research, agglomeration: agglomeration)
      property = FactoryBot.create(:property)
      post "/api/v1/saved_properties", params: { property_id: property.id, research_id: research.id } , headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      agglomeration = FactoryBot.create(:agglomeration)
      research = FactoryBot.create(:subscriber_research, agglomeration: agglomeration)
      saved_property = FactoryBot.create(:saved_property, research_id: research.id)
      delete "/api/v1/saved_properties/#{saved_property.id}", params: {}, headers: headers
      expect(response).to have_http_status(:success)
    end
  end

end
