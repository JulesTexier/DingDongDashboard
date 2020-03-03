class Api::V1::SubscribersController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    require 'dotenv/load'
    TOKEN = ENV['BEARER_TOKEN']

    before_action :authentificate

    # GET /subscribers
    def index
        @subscribers = Subscriber.all
        render json: {status: 'SUCCESS', message: 'List of all users', data: @subscribers}, status: 200
    end

    # GET /subscribers/:id
    def show
        begin
            @subscriber = Subscriber.find(params[:id])
            render json: {status: 'SUCCESS', message: 'Required subscriber', data: @subscriber}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
        end
    end

    # GET /subscribers/fb/:facebook_id
    def show_facebook_id
        @subscriber = Subscriber.where(facebook_id: params[:facebook_id]).first
        if  !@subscriber.nil?
            render json: {status: 'SUCCESS', message: 'Required subscriber', data: @subscriber}, status: 200
        else
            render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
        end
    end

    # POST /subscribers/
    def create 
        sub = Subscriber.new(subscriber_params)
        if sub.save
            render json: {status: 'SUCCESS', message: 'Subscriber created', data: sub}, status: 200
        else
            render json: {status: 'ERROR', message: 'Subscriber could not be created', data: sub.errors}, status: 500
        end
    end

    # PUT /subscribers/:id
    def update 
        begin
            @subscriber = Subscriber.find(params[:id])
            @subscriber.update(subscriber_params)
            render json: {status: 'SUCCESS', message: 'Subscriber updated', data: @subscriber}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
        end
    end

     # DELETE /subscribers/:id
     def destroy 
        begin
            @subscriber = Subscriber.find(params[:id])
            @subscriber.destroy
            render json: {status: 'SUCCESS', message: 'Subscriber deleted', data: @subscriber}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
        end
    end

    #GET /subscribers/:subscriber_id/props/last/:x/days
    # Get number of properties tha tmatch Subscriber criteria in the last X days
    def props_x_days
        @subscriber = Subscriber.find(params[:subscriber_id])
        render json: {status: 'SUCCESS', message: 'Subscriber found in DB', data: @subscriber.get_props_in_lasts_x_days(params[:x]).length}, status: 200
    end

    #GET /subscribers/:subscriber_id/send/props/last/:x/days
    # Send properties that match Subscriber criteria in the last X days
    def send_props_x_days
        begin
            @subscriber = Subscriber.find(params[:subscriber_id])
            props = @subscriber.get_props_in_lasts_x_days(params[:x])
            props.length > 0 ? (render json: send_multiple_properties(@subscriber, props) ) : (render json: {status: 'ERROR', message: 'There is no latest props for this subscriber', data: nil}, status: 404)
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
        end
    end

    # #GET /subscribers/:subscriber_id/send/props/morning
    # # Send properties that match Subscriber criteria during past night
    # def send_props_morning
    #     begin
    #         @subscriber = Subscriber.find(params[:subscriber_id])
    #         props = @subscriber.get_morning_props
    #         props.length > 0 ? (render json: send_multiple_properties(@subscriber, props) ): (render json: {status: 'ERROR', message: 'There is no morning for this subscriber', data: nil}, status: 404)
    #     rescue ActiveRecord::RecordNotFound
    #         render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
    #     end
    # end

    # #GET /subscribers/:subscriber_id/send/props/:property_id/details
    # # Send a property details to a subscriber
    # def send_prop_details
    #     begin
    #         @subscriber = Subscriber.find(params[:subscriber_id])
    #         begin
    #             property = Property.find(params[:property_id])

    #             m = Manychat.new
    #             response = m.send_property_info_post_interaction(@subscriber, property)
    #             puts response

    #             if response[0]
    #                 render json: {status: 'SUCCESS', message: "Property sent to subscriber", data: response[1]}, status: 200
    #             else
    #                 render json: {status: 'ERROR', message: 'A error occur in manychat call', data: response[1]}, status: 500
    #             end
    #         rescue ActiveRecord::RecordNotFound
    #             render json: {status: 'ERROR', message: 'Property not found', data: nil}, status: 404
    #         end
    #     rescue ActiveRecord::RecordNotFound
    #         render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
    #     end
    # end

    # #GET /subscribers/:subscriber_id/props/favorites
    # # Send properties that match Subscriber criteria during past night
    # def send_props_favorites
    #     begin
    #         @subscriber = Subscriber.find(params[:subscriber_id])
    #         props = @subscriber.fav_properties
    #         props.length > 0 ? (render json: send_multiple_properties(@subscriber, props) ) : (render json: {status: 'ERROR', message: 'There is no favorites for this subscriber', data: nil}, status: 404)
    #     rescue ActiveRecord::RecordNotFound
    #         render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
    #     end
    # end



    private

    def subscriber_params
        params.permit(:firstname, :lastname, :email, :phone, :facebook_id)
    end

    def authentificate
        authenticate_or_request_with_http_token do |token, options|
            ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
        end
    end

    

end
