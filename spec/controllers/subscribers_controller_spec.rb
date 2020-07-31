require "rails_helper"

RSpec.describe SubscribersController, type: :controller do
  before(:all) do
  end
  describe "GET #edit" do
    before do
      sub = FactoryBot.create(:subscriber_dummy_fb_id)
      research = FactoryBot.create(:subscriber_research, subscriber: sub)
      research.areas << Area.first
      get :edit, params: { id: sub.id }
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "renders the edit template" do
      expect(response).to render_template("edit")
    end
  end
end
