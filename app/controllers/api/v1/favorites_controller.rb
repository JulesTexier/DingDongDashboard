class Api::V1::FavoritesController < ApplicationController

    include ActionController::HttpAuthentication::Token::ControllerMethods

    require 'dotenv/load'
    TOKEN = ENV['BEARER_TOKEN']

    before_action :authentificate

    # POST /favorites/
    def create 
        fav = Favorite.new(favorite_params)
        if fav.save
            render json: {status: 'SUCCESS', message: 'Favorite created', data: fav}, status: 200
        else
            render json: {status: 'ERROR', message: 'Favorite could not be created', data: fav.errors}, status: 500
        end
    end

     # DELETE /subscribers/:id
     def destroy 
        begin
            @fav = Favorite.find(params[:id])
            @fav.destroy
            render json: {status: 'SUCCESS', message: 'Favorite deleted', data: @fav}, status: 200
        rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Favorite not found', data: nil}, status: 404
        end
    end



    private


    def authentificate
        authenticate_or_request_with_http_token do |token, options|
            ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
        end
    end

    def favorite_params
        params.permit(:subscriber_id, :property_id)
    end

end
