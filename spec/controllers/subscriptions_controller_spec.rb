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

    it "should return false for is_client" do
      get :index, params: { subscriber_id: @subscriber.id }
      expect(@subscriber.is_subscriber_premium?).to eq(false)
    end

    it "should return false for is_client" do
      get :cancel, params: { subscriber_id: @subscriber.id }
      expect(response).to have_http_status(:ok)
    end

    it "should return false for is_client" do
      get :cancel, params: { subscriber_id: @subscriber.id }
      expect(@subscriber.is_subscriber_premium?).to eq(false)
    end

    # it "should return false for is_client" do
    #   get :success, params: { subscriber_id: @subscriber.id, session_id: "fake_session_lol_127392173" }
    #   expect(response).to have_http_status(:ok)
    #   expect(@subscriber.is_subscriber_premium?).to eq(true)
    #   expect(@subscriber.stripe_session_id).to eq("fake_session_lol_127392173")
    #   expect(@subscriber.is_blocked).to eq(false)
    # end
  end
end
