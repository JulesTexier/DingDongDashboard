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
            subscriber = Subscriber.find(params[:id])
            data = subscriber.as_json
            data[:areas_list] = subscriber.get_areas_list
            data[:districts_list] = subscriber.get_districts_list
            data[:edit_path] = subscriber.get_edit_path
            data[:business_model] = subscriber.get_bm
            render json: {status: 'SUCCESS', message: 'Required subscriber', data: data}, status: 200
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

    # POST /suscribers/fb/:facebook_id
    def create_from_facebook_id
        sub  = Subscriber.find_by(facebook_id: params[:facebook_id])
        @subscriber = sub.nil? ? Subscriber.create(facebook_id: params[:facebook_id]) : sub
        data = @subscriber.as_json
        data[:edit_path] = @subscriber.get_edit_path
        if !@subscriber.id.nil?
            render json: {status: 'SUCCESS', message: 'Subscriber created', data: data}, status: 200
        else
            render json: {status: 'ERROR', message: 'Subscriber could not be created', data: nil}, status: 500
        end

    end

    # POST /subscribers/:id/broker/
    def atttribute_broker
        @subscriber  = Subscriber.find(params[:id])
        @subscriber.handle_onboarding_end_manychat
        if !@subscriber.trello_id_card.nil?
            render json: {status: 'SUCCESS', message: 'Subscriber created', data: @subscriber}, status: 200
        else 
            render json: {status: 'ERROR', message: 'Broker not attributed => Trello card not created', data: nil}, status: 500
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


    private

    def subscriber_params
        params.permit(:firstname, :lastname, :email, :phone, :facebook_id, :is_active, :max_price, :min_surface, :trello_id_card, :broker_id)
    end

    def authentificate
        authenticate_or_request_with_http_token do |token, options|
            ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
        end
    end

    

end
