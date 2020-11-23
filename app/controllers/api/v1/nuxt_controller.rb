require 'dotenv/load'

class Api::V1::NuxtController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  TOKEN = ENV['BEARER_TOKEN']
  HIDE_DAY_COUNT = 7
  protect_from_forgery with: :null_session
  before_action :authentificate

  # def encode_token(payload)
  #   JWT.encode(payload, 's3cr3t')
  # end

  # def auth_header
  #   # { Authorization: 'Bearer <token>' }
  #   request.headers['Authorization']
  # end

  # def decoded_token
  #   if auth_header
  #     token = auth_header.split(' ')[1]
  #     # header: { 'Authorization': 'Bearer <token>' }
  #     begin
  #       JWT.decode(token, 's3cr3t', true, algorithm: 'HS256')
  #     rescue JWT::DecodeError
  #       nil
  #     end
  #   end
  # end

  # def logged_in_user
  #   if decoded_token
  #     user_id = decoded_token[0]['user_id']
  #     @user = User.find_by(id: user_id)
  #   end
  # end

  # def logged_in?
  #   !!logged_in_user
  # end

  def get_dashboard_leads
    @broker = Broker.find(params[:id])
    if !@broker.nil?
      dd_subs_all = @broker.subscribers.where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day)
      dd_subs = dd_subs_all.order('created_at DESC').select{|s| (!s.has_stopped || s.has_stopped && (s.has_stopped_at - s.created_at) > 7.days) }.as_json.each{|s| s[:contact_type] = "Ding Dong"}
      dd_subs_out = dd_subs_all.order('created_at DESC').select{|s| (s.has_stopped && (s.has_stopped_at - s.created_at) <= 7.days) }.as_json.each{|s| s[:contact_type] = "Se Loger"}
      sl_subs = @broker.subscribers.where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).where(status:"new_lead").order('created_at DESC').as_json.each{|s| s[:contact_type] = "Se Loger"}
      data = dd_subs + sl_subs + dd_subs_out

      render json: {status: 'SUCCESS', message: "Here is the list of the #{data.count} leads for broker #{@broker.id} ", data: data}, status: 200
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

  def auth_login
    broker = Broker.find_by(email: params["email"])
    if !broker.nil? && BCrypt::Password.new(broker.encrypted_password) == params["password"]
    # if broker && broker.authenticate(params["password"])
      # render json: {status: 'SUCCESS', message: "Broker logged in"}, status: 200
      render json: {token: "toner"}, status: 200
    else 
      render json: {status: 'ERROR', message: 'Broker not authorized'}, status: 400
    end
  end

  def auth_user
    byebug
    render json: @broker, status: 200
  end

  private
  def authentificate
      authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
  end

  def subscriber_params
    params.except(:id, :nuxt).permit(:firstname, :lastname, :email, :phone, :facebook_id, :broker_status, :broker_comment )
  end
end
