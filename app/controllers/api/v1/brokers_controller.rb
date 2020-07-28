require 'dotenv/load'

class Api::V1::BrokersController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  TOKEN = ENV['BEARER_TOKEN']
  protect_from_forgery with: :null_session
  before_action :authentificate

  def show 
    @broker = Broker.find(params[:id])
    if !@broker.nil?
      render json: {status: 'SUCCESS', message: 'Broker found', data: @broker}, status: 200
    else
      render json: {status: 'ERROR', message: 'Broker not found'}, status: 404
    end
  end

  private
  def authentificate
      authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
  end
end
