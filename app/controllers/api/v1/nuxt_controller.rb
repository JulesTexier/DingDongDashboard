require 'dotenv/load'

class Api::V1::NuxtController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  TOKEN = ENV['BEARER_TOKEN']
  HIDE_DAY_COUNT = 7
  protect_from_forgery with: :null_session
  before_action :authenticate

  def get_subscriber
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      render json: {status: 'SUCCESS', message: "Subscriber found successfully", data: subscriber}, status: 200
    rescue ActiveRecord::RecordNotFound => e
      render json: {status: 'ERROR', message: 'Subscriber not found'}, status: 422
    end
  end

  def get_broker
    begin
      broker = Broker.find(params[:broker_id])
      render json: {status: 'SUCCESS', message: "Broker found successfully", data: broker}, status: 200
    rescue ActiveRecord::RecordNotFound => e  
      render json: {status: 'ERROR', message: 'Broker not found'}, status: 422
    end
  end

  def get_dashboard_leads
    broker = Broker.find(params[:id])
    if !broker.nil?
      scoped_subscribers = broker.get_available_leads
      data = scoped_subscribers.map{ |s| s.is_real_ding_dong_user? ? s.as_json.merge!(contact_type: "Ding Dong") : s.as_json.merge!(contact_type: "Se Loger")  }
      render json: {status: 'SUCCESS', message: "Here is the list of the #{data.count} leads for broker #{broker.id} ", data: data}, status: 200
    else
      render json: {status: 'ERROR', message: 'Broker not found'}, status: 422
    end
  end

  def update_subscriber
    @subscriber = Subscriber.find(params[:id])
    if !@subscriber.nil?
      @subscriber.update(subscriber_params)
      render json: {status: 'SUCCESS', message: "Subscriber updated", data: @subscriber.as_json}, status: 200
    else
      render json: {status: 'ERROR', message: 'Subscriber not found'}, status: 422
    end
  end

  def get_available_areas
    @areas = Area.opened
    @areas_augmented = @areas.as_json
    @areas_augmented.each_with_index do |area, index| 
      area[:agglomeration] = @areas[index].department.agglomeration.name
      area[:department] = Department.find(area["department_id"]).name
    end
    render json: {status: 'SUCCESS', message: "Opened areas", data: @areas_augmented}, status: 200
  end

  private
  def authenticate
      authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
  end

  def subscriber_params
    params.except(:id, :nuxt).permit(:firstname, :lastname, :email, :phone, :facebook_id, :broker_status, :broker_comment, :hot_lead, :broker_meeting)
  end
end
