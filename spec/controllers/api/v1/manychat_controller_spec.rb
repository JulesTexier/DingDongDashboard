require 'rails_helper'
require "dotenv/load"

RSpec.describe Api::V1::ManychatController, type: :controller do

    describe "A subscriber should receive his favorites" do 

        sub = FactoryBot.create(:subscriber_fred)

        context "#send_favorites" do 
           
            it 'should contain an authorization token' do 
                get :send_props_favorites, params: { subscriber_id: sub.id }
                expect(response.body).to eq("HTTP Token: Access denied.\n")         
            end

            it 'should have 200 https status' do
                request.headers.merge!({ 'Authorization':  "Bearer " + ENV["BEARER_TOKEN"]})
                get :send_props_favorites, params: { subscriber_id: sub.id }
                expect(response).to have_http_status(:success)
            end
        end

    end

end
