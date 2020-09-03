require 'dotenv/load'

class Api::V1::NotariesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  TOKEN = ENV['BEARER_TOKEN']
  protect_from_forgery with: :null_session
  before_action :authentificate

  def show 
    @notary = Notary.find(params[:id])
    if !@notary.nil?
      render json: {status: 'SUCCESS', message: 'Notary found', data: @notary}, status: 200
    else
      render json: {status: 'ERROR', message: 'Notary not found'}, status: 404
    end
  end

  private
  def authentificate
      authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
  end
end
