require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller do
  before :each do
    @subscriber = FactoryBot.create(:subscriber)
    FactoryBot.create(:status, name: "onboarded")
    FactoryBot.create(:status, name: "has_paid_subscription")
    FactoryBot.create(:status, name: "has_ended_subscription")
    FactoryBot.create(:status, name: "has_cancelled_subscription")
    @subscriber.statuses << Status.find_by(name: "onboarded")
  end
  describe "get #index" do
    it "should return false for is_client" do
      get :index, params: { subscriber_id: @subscriber.id }
      expect(response).to have_http_status(:ok)
    end

    it "should return ok for cancel page" do
      get :cancel, params: { subscriber_id: @subscriber.id }
      expect(response).to have_http_status(:ok)
    end

    it "should return ok" do
      get :success, params: { subscriber_id: @subscriber.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
