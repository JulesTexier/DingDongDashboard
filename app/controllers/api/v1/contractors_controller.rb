require 'dotenv/load'

class Api::V1::ContractorsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  TOKEN = ENV['BEARER_TOKEN']
  protect_from_forgery with: :null_session
  before_action :authentificate

  def show 
    @contractor = Contractor.find(params[:id])
    if !@contractor.nil?
      render json: {status: 'SUCCESS', message: 'Contractor found', data: @contractor}, status: 200
    else
      render json: {status: 'ERROR', message: 'Contractor not found'}, status: 404
    end
  end

  private
  def authentificate
      authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
  end
end
