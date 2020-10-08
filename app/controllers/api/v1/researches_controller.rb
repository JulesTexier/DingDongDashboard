require 'dotenv/load'

class Api::V1::ResearchesController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    TOKEN = ENV['BEARER_TOKEN']
    before_action :authentificate


    # GET 
    def index
        @researches = Research.all
        render json: {status: 'SUCCESS', message: 'List of all researched', data: @researches}, status: 200
    end

    # GET 
    def show
        begin
            research = Research.find(params[:id])
            data = research.as_json
            data[:areas_list] = research.get_areas_list
            render json: {status: 'SUCCESS', message: 'Required research', data: data}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Research not found', data: nil}, status: 404
        end
    end

    # POST 
    def create 
        sub = Research.new(research_params)
        if sub.save
            render json: {status: 'SUCCESS', message: 'Research created', data: sub}, status: 200
        else
            render json: {status: 'ERROR', message: 'Research could not be created', data: sub.errors}, status: 500
        end
    end

    # PUT 
    def update 
        begin
            @research = Research.find(params[:id])
            @research.update(research_params)
            render json: {status: 'SUCCESS', message: 'Research updated', data: @research}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Research not found', data: nil}, status: 404
        end
    end

     # DELETE 
     def destroy 
        begin
            @research = Research.find(params[:id])
            @research.destroy
            render json: {status: 'SUCCESS', message: 'research deleted', data: @research}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Research not found', data: nil}, status: 404
        end
    end

    private

    def research_params
        params.permit(:agglomeration_id, :min_floor, :has_elevator, :min_elevator_floor, :min_surface, :min_rooms_number, :max_price, :min_price, :max_sqm_price, :balcony, :terrace, :garden, :new_construction, :last_floor, :home_type, :appartement_type, :subscriber_id)
    end

    def authentificate
        authenticate_or_request_with_http_token do |token, options|
            ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
        end
    end
end
