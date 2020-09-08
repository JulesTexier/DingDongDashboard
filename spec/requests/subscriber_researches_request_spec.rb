require 'rails_helper'

RSpec.describe "SubscriberResearches", type: :request do

  describe "GET /subscriber_researches/agglomeration" do
    it "returns http success" do
      get "/subscriber_researches/agglomeration"
      expect(response).to have_http_status(:success)
    end
  end

end
