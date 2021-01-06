require 'dotenv/load'

class Api::V1::SubscribersDashboardController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_and_set_subscriber

    def current 
        returned_subscriber = current_subscriber.as_json
        returned_subscriber[:research] = current_subscriber.research
        returned_subscriber[:areas] = current_subscriber.research.areas
        render json: {user: returned_subscriber}, status: 200
    end

    def research_properties
        begin 
            properties = ResearchManager::ResearchProperties.call(current_subscriber.research.id, 120)
            data = properties.map{|p| {property: p, area: p.area}}
            render json: {status: 'SUCCESS', message: "Matching properties", data: data}, status: 200
        rescue 
            render json: {status: 'ERROR', message: 'Subscriber\'s research not found'}, status: 422     
        end
    end

    def update
        begin 
            current_subscriber.update(subscriber_params)
            render json: {status: 'SUCCESS', message: "Subscriber has been updated", data: current_subscriber}, status: 200
        rescue 
            render json: {status: 'ERROR', message: 'Subscriber could no be updated'}, status: 422     
        end
    end

    private

    def subscriber_params
        params.require(:subscribers_dashboard).permit(:firstname, :lastname, :email, :phone, :facebook_id, :broker_status, :broker_comment, :hot_lead, :broker_meeting)
      end
    

end
