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

    # def get_properties
    #     current_subscriber.
    # end



    private

end
