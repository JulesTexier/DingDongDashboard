class Api::V1::PropertiesController < ApplicationController

    include ActionController::HttpAuthentication::Token::ControllerMethods

    require 'dotenv/load'
    TOKEN = ENV['BEARER_TOKEN']

    before_action :authentificate

    # GET /properties
    def index
        @properties = Property.all
        render json: {status: 'SUCCESS', message: 'List of all properties', data: @properties}, status: 200
    end

    # GET properties/:id
    def show
        begin
            @properties = Property.find(params[:id])
            render json: {status: 'SUCCESS', message: 'Requested property', data: @properties}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Property not found', data: nil}, status: 404
        end
    end


    private


    def authentificate
        authenticate_or_request_with_http_token do |token, options|
            ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
        end
    end

end
