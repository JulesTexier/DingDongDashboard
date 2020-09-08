require 'dotenv/load'

class Api::V1::SubscribersController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

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
            data[:edit_path] = subscriber.get_edit_path
            data[:research_id] = subscriber.research.id
            render json: {status: 'SUCCESS', message: 'Required subscriber', data: data}, status: 200
        rescue ActiveRecord::RecordNotFound
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

    # GET /subscribers/fb/:facebook_id
    def show_facebook_id
        @subscriber = Subscriber.where(facebook_id: params[:facebook_id]).first
        if  !@subscriber.nil?
            render json: {status: 'SUCCESS', message: 'Required subscriber', data: @subscriber}, status: 200
        else
            render json: {status: 'ERROR', message: 'Subscriber not found', data: nil}, status: 404
        end
    end

    # POST /suscribers/fb/:facebook_id
    def create_from_facebook_id
        # sub  = Subscriber.find_by(facebook_id: params[:facebook_id])
        # @subscriber = sub.nil? ? Subscriber.new(facebook_id: params[:facebook_id]) : sub
        @subscriber = Subscriber.new(facebook_id: params[:facebook_id]) 
        if @subscriber.save(context: :facebook_creation)
            data = @subscriber.as_json
            data[:edit_path] = @subscriber.get_edit_path
            render json: {status: 'SUCCESS', message: 'Subscriber created', data: data}, status: 200
        else
            render json: {status: 'ERROR', message: 'Subscriber could not be created', data: @subscriber.errors}, status: 500
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
