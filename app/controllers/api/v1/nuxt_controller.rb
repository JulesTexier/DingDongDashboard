require 'dotenv/load'

class Api::V1::NuxtController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  TOKEN = ENV['BEARER_TOKEN']
  HIDE_DAY_COUNT = 7
  protect_from_forgery with: :null_session
  before_action :authenticate

  def get_dashboard_leads
    @broker = Broker.find(params[:id])
    if !@broker.nil?
      # All subscribers in DB created before HIDE_DAY_COUNT period
      scoped_subscribers = @broker.subscribers.where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).order('created_at DESC')
      # Subscribers that use DD alert 
      dd_subs_all = scoped_subscribers.where.not(status: "new_lead")
      dd_subs = dd_subs_all.select{|s| (!s.has_stopped || s.has_stopped && (s.has_stopped_at - s.created_at) > 7.days) }.as_json.each{|s| s[:contact_type] = "Ding Dong"}
      # Reflag as ghost contact( bad DD xp )
      dd_subs_out = dd_subs_all.select{|s| (s.has_stopped && (s.has_stopped_at - s.created_at) <= 7.days) }.as_json.each{|s| s[:contact_type] = "Se Loger"}
      
      # Ghost contacts
      sl_subs = scoped_subscribers.where(status:"new_lead").as_json.each{|s| s[:contact_type] = "Se Loger"}
      
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
