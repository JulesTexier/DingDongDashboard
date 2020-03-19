require "rails_helper"
require "dotenv/load"

RSpec.describe Api::V1::ManychatController, type: :controller do

  describe "Subscriber operations" do 
    describe "Update subscriber atributes form manychat" do 
      context "#update_subscriber" do 
        before :all do
          @sub = FactoryBot.create(:subscriber)
        end
        it "should contain an authorization token" do
          post :update_subscriber, params: {subscriber_id: @sub.id}
          expect(response.body).to eq("HTTP Token: Access denied.\n")
        end
        it "should have 200 https status" do
          request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          post :update_subscriber, params: {subscriber_id: @sub.id}
          expect(response).to have_http_status(:success)
        end
        it "should respond 404 status id subscriber is not found" do
          request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          post :update_subscriber, params: {subscriber_id: 9999}
          expect(response).to have_http_status(404)
        end
        it "update subscriber firstname" do
          request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          sub = @sub
          sub.firstname = 'Paul'
          post :update_subscriber, params: {subscriber_id: @sub.id, subscriber: sub}
          expect(@sub.firstname).to eq('Paul')
        end
      end
    end
  end


  # describe "A subscriber should receive his favorites" do
  #   context "#send_favorites" do
  #     before :all do
  #       @sub = FactoryBot.create(:subscriber_fred)
  #     end
  #     it "should contain an authorization token" do
  #       get :send_props_favorites, params: { subscriber_id: @sub.id }
  #       expect(response.body).to eq("HTTP Token: Access denied.\n")
  #     end

  #     it "should have 200 https status" do
  #       request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
  #       get :send_props_favorites, params: { subscriber_id: @sub.id }
  #       expect(response).to have_http_status(:success)
  #     end
  #   end
  # end
end
