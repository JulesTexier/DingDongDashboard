class Api::V1::LeadsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  protect_from_forgery with: :null_session
  require 'dotenv/load'
  TOKEN = ENV['BEARER_TOKEN']

  protect_from_forgery with: :null_session
  before_action :authentificate

  def index 
    @leads = Lead.all
    render json: {status: 'SUCCESS', message: 'List of all leads', data: @leads}, status: 200
  end

  # PUT /lead/:id
  def update 
    begin
        @lead = Lead.find(params[:id])
        @lead.update(lead_params)
        render json: {status: 'SUCCESS', message: 'Lead updated', data: @lead}, status: 200
    rescue ActiveRecord::RecordNotFound
        render json: {status: 'ERROR', message: 'Lead not found', data: nil}, status: 404
    end
  end

  private

    def lead_params
        params.permit(:id, :name, :email, :phone, :status, :broker_id)
    end

    def authentificate
        authenticate_or_request_with_http_token do |token, options|
            ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
        end
    end


end
