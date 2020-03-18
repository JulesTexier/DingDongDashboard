require "rails_helper"

RSpec.describe SubscribersController, type: :controller do
  describe "GET #edit" do
    before do
      sub = FactoryBot.create(:subscriber)
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
