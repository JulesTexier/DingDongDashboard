require 'dotenv/load'
include ActionController::HttpAuthentication::Token::ControllerMethods

class Api::V1::PropertiesController < ApplicationController
  TOKEN = ENV['BEARER_TOKEN']
  before_action :authentificate


  # GET /properties
  def index
    render json: {status: 'SUCCESS', message: 'List of all properties', data: Property.all}, status: 200
  end

  # GET properties/:id
  def show
    begin
      @property = Property.find(params[:id])
      render json: {status: 'SUCCESS', message: 'Requested property', data: @property}, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {status: 'ERROR', message: 'Property not found', data: nil}, status: 422
    end
  end

  private
  def authentificate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end
