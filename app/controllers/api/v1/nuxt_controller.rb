require 'dotenv/load'

class Api::V1::NuxtController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  TOKEN = ENV['BEARER_TOKEN']
  HIDE_DAY_COUNT = 7
  protect_from_forgery with: :null_session
  before_action :authenticate

  def get_dashboard_leads
    broker = Broker.find(params[:id])
    if !broker.nil?
      scoped_subscribers = broker.get_available_leads
      data = scoped_subscribers.map{ |s| s.is_real_ding_dong_user? ? s.as_json.merge!(contact_type: "Ding Dong") : s.as_json.merge!(contact_type: "Se Loger")  }
      render json: {status: 'SUCCESS', message: "Here is the list of the #{data.count} leads for broker #{broker.id} ", data: data}, status: 200
    else
      render json: {status: 'ERROR', message: 'Broker not found'}, status: 400
    end
  end

  def update_subscriber
    @subscriber = Subscriber.find(params[:id])
    if !@subscriber.nil?
      @subscriber.update(subscriber_params)
      render json: {status: 'SUCCESS', message: "Subscriber updated", data: @subscriber.as_json}, status: 200
    else
      render json: {status: 'ERROR', message: 'Subscriber not found'}, status: 400
    end
  end

  private
  def authenticate
      authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
  end

  def subscriber_params
    params.except(:id, :nuxt).permit(:firstname, :lastname, :email, :phone, :facebook_id, :broker_status, :broker_comment )
  end
end
