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
          post :update_subscriber, params: { subscriber_id: @sub.id }
          expect(response.body).to eq("HTTP Token: Access denied.\n")
        end
        it "should have 200 https status" do
          request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          post :update_subscriber, params: { subscriber_id: @sub.id }
          expect(response).to have_http_status(:success)
        end
        it "should respond 404 status id subscriber is not found" do
          request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          post :update_subscriber, params: { subscriber_id: 9999 }
          expect(response).to have_http_status(404)
          expect(JSON.parse(response.body)["message"]).to eq("Subscriber not found")
        end
        it "should update subscriber" do
          request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          sub = @sub
          sub.firstname = "John"
          params = {
            subscriber_id: @sub.id,
            subscriber: sub,
          }
          post :update_subscriber, params: params
          expect(@sub.firstname).to eq("John")
        end
      end
    end
  end

  describe "Manychat send methods" do
    before :all do
      @sub = FactoryBot.create(:subscriber_fred, max_price: 500000, min_surface: 20, min_rooms_number: 1, min_floor: 2, min_elevator_floor: 4)
      @sub.areas << Area.new(name: "Paris 10ème")
      date = Date.today
      date = Time.parse(date.to_time.in_time_zone("Europe/Paris").beginning_of_day.to_s)
      @property = FactoryBot.create(:property, created_at: date, price: @sub.max_price, surface: @sub.min_surface, area: @sub.areas.first, rooms_number: @sub.min_rooms_number, floor: nil, has_elevator: nil)
      FactoryBot.create(:favorite, subscriber: @sub, property: @property)
    end

    describe "send last X properties to a subscriber" do
      context "#send_x_last_props" do
        it "should contain an authorization token" do
          get :send_x_last_props, params: { subscriber_id: @sub.id, x: 1 }
          expect(response.body).to eq("HTTP Token: Access denied.\n")
        end

        # it "should have 200 https status" do
        #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
        #   get :send_x_last_props, params: { subscriber_id: @sub.id, x: 1 }
        #   expect(response).to have_http_status(:success)
        # end
        # it "should respond 404 status id subscriber is not found" do
        #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
        #   post :send_x_last_props, params: { subscriber_id: 9999, x: 1 }
        #   expect(response).to have_http_status(404)
        #   expect(JSON.parse(response.body)["message"]).to eq("Subscriber not found")
        # end
        # it 'should return Manychat error "subscriber not found"' do
        #   sub = FactoryBot.create(:subscriber_dummy_fb_id)
        #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
        #   post :send_props_morning, params: { subscriber_id: sub.id }
        #   expect(response).to have_http_status(406)
        #   expect(JSON.parse(response.body)["data"]["message"]).to eq("Validation error")
        #   expect(JSON.parse(response.body)["data"]["details"]["messages"][0]["message"]).to eq("Subscriber does not exist")
        # end
      end
    end

    describe "send morning properties to a subscriber" do
      context "#send_props_morning" do
        context "DD response side" do
          # it "should contain an authorization token" do
          #   get :send_props_morning, params: { subscriber_id: @sub.id }
          #   expect(response.body).to eq("HTTP Token: Access denied.\n")
          # end

          # it "should have 200 https status" do
          #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          #   get :send_props_morning, params: { subscriber_id: @sub.id }
          #   expect(response).to have_http_status(:success)
          # end
          # it "should respond 404 status id subscriber is not found" do
          #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          #   post :send_props_morning, params: { subscriber_id: 9999 }
          #   expect(response).to have_http_status(404)
          #   expect(JSON.parse(response.body)["message"]).to eq("Subscriber not found")
          # end
          # it 'should return Manychat error "subscriber not found"' do
          #   sub = FactoryBot.create(:subscriber_dummy_fb_id)
          #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
          #   post :send_props_morning, params: { subscriber_id: sub.id }
          #   expect(response).to have_http_status(406)
          #   expect(JSON.parse(response.body)["data"]["message"]).to eq("Validation error")
          #   expect(JSON.parse(response.body)["data"]["details"]["messages"][0]["message"]).to eq("Subscriber does not exist")
          # end
        end
      end
    end

    describe "A subscriber should receive his favorites" do
      context "#send_favorites" do
        # it "should contain an authorization token" do
        #   get :send_props_favorites, params: { subscriber_id: @sub.id }
        #   expect(response.body).to eq("HTTP Token: Access denied.\n")
        # end

        # it "should have 200 https status" do
        #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
        #   get :send_props_favorites, params: { subscriber_id: @sub.id }
        #   expect(response).to have_http_status(:success)
        # end
        # it "should respond 404 status id subscriber is not found" do
        #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
        #   post :send_props_favorites, params: { subscriber_id: 9999 }
        #   expect(response).to have_http_status(404)
        #   expect(JSON.parse(response.body)["message"]).to eq("Subscriber not found")
        # end
        # it 'should return Manychat error "subscriber not found"' do
        #   sub = FactoryBot.create(:subscriber_dummy_fb_id)
        #   request.headers.merge!({ 'Authorization': "Bearer " + ENV["BEARER_TOKEN"] })
        #   post :send_props_favorites, params: { subscriber_id: sub.id }
        #   expect(response).to have_http_status(406)
        #   expect(JSON.parse(response.body)["data"]["message"]).to eq("Validation error")
        #   expect(JSON.parse(response.body)["data"]["details"]["messages"][0]["message"]).to eq("Subscriber does not exist")
        # end
      end
    end
  end
end
