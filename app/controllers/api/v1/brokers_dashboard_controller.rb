require 'dotenv/load'

class Api::V1::BrokersDashboardController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_and_set_broker

  def current 
      returned_broker = current_broker.as_json
      scoped_subscribers = current_broker.get_available_leads
      brokers_in_agency = current_broker.broker_agency.nil? ? current_broker : current_broker.broker_agency.brokers
      if current_broker.broker_agency.only_dd_users
        data = scoped_subscribers.select{|s| s.is_real_ding_dong_user? }.map{ |s|  s.as_json.merge!(contact_type: "Ding Dong", research: s.research, areas: s.research.nil? ? nil : s.research.areas, subscriber_notes: s.subscriber_notes, brokers: brokers_in_agency)  }
      else
        data = scoped_subscribers.map{ |s| s.is_real_ding_dong_user? ? s.as_json.merge!(contact_type: "Ding Dong", research: s.research, areas: s.research.areas, subscriber_notes: s.subscriber_notes, brokers: brokers_in_agency) : s.as_json.merge!(contact_type: "Se Loger", brokers: brokers_in_agency)  }
      end
      returned_broker[:leads] = data
      render json: {user: returned_broker}, status: 200
  end

  def update_subscriber
    begin
      subscriber = current_broker.subscribers.find(params[:subscriber_id])
      subscriber.update(subscriber_params)
      render json: {status: 'SUCCESS', message: "Subscriber updated", data: subscriber.as_json}, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: {status: 'ERROR', message: 'Subscriber not found'}, status: 422   
    end
  end

  private 

  def subscriber_params
    params.except(:id, :nuxt).permit(:firstname, :lastname, :email, :phone, :facebook_id, :broker_status, :broker_id, :broker_comment, :hot_lead, :broker_meeting)
  end

end