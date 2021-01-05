require 'dotenv/load'

class Api::V1::NuxtController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  protect_from_forgery with: :null_session

  TOKEN = ENV['BEARER_TOKEN']
  HIDE_DAY_COUNT = 7
  protect_from_forgery with: :null_session
  before_action :authenticate

  def get_subscriber
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      returned_subscriber = subscriber.as_json
      returned_subscriber[:research] = subscriber.research
      returned_subscriber[:areas] = subscriber.research.areas
      render json: {status: 'SUCCESS', message: "Subscriber found successfully", data: returned_subscriber}, status: 200
    rescue ActiveRecord::RecordNotFound => e
      render json: {status: 'ERROR', message: 'Subscriber not found'}, status: 422
    end
  end

  def get_research
    begin
      research = Research.find(params[:research_id])
      research_augmented = research.as_json 
      research_augmented[:areas] = research.areas
      render json: {status: 'SUCCESS', message: "Research found successfully", data: research_augmented}, status: 200
    rescue ActiveRecord::RecordNotFound => e
      render json: {status: 'ERROR', message: 'Research not found'}, status: 422
    end
  end 

  def is_subscriber_exists?
    begin
      if params[:phone].nil? && params[:email].nil?
        render json: {status: 'ERROR', message: 'Email or phone required'}, status: 422
      else 
        subscribers = Subscriber.ding_dong_users.where(params.except(:id, :nuxt).permit(:phone, :email))
        render json: {status: 'SUCCESS', message: "#{subscribers.count} Subscriber#{"s" if subscribers.count > 1 } found", data: subscribers}, status: 200
      end
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

  def handle_onboarding
    begin
      subscriber = Subscriber.create(onboarding_subscriber_params)

      research = Research.new(onboarding_research_params)
      research.subscriber = subscriber
      research.agglomeration = Area.find(params["areas"].first).department.agglomeration
      research.save

      params["areas"].each{|area_id| ResearchArea.create(research: research, area_id: area_id) }

      subscriber.handle_onboarding

      returned_subscriber = subscriber.as_json
      returned_subscriber[:messenger_link] = subscriber.messenger_link
      returned_subscriber[:research] = subscriber.research
      returned_subscriber[:areas] = subscriber.research.areas
      render json: {status: 'SUCCESS', message: "Subscriber successfully created", data: returned_subscriber}, status: 200
    rescue 
      render json: {status: 'ERROR', message: 'An error occurred'}, status: 422
    end
  end

  def new_meeting_notify_broker
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      BrokerJob.set(wait: 10.minutes).perform_later(subscriber.id)
      render json: {status: 'SUCCESS', message: "Notification sent to broker", data: ""}, status: 200
    rescue ActiveRecord::RecordNotFound => e
      render json: {status: 'ERROR', message: 'Subscriber not found'}, status: 422      
    end
  end

  def verify_email_subscriber
    subscriber = Subscriber.find_by(confirm_token: params[:subscriber_token])
    unless subscriber.nil?
      subscriber.validate_email
      subscriber.save(validate: true)
      SubscriberMailer.welcome_email(subscriber).deliver_now
      render json: {status: 'SUCCESS', message: "Email verified", data: ""}, status: 200
    else
      render json: {status: 'ERROR', message: 'Subscriber not found'}, status: 422      
    end
  end

  def get_estimation
    begin
      nb_properties = ResearchManager::ResearchIndicator.call(params[:research_hash].as_json, params[:areas], params[:nb_days])
      render json: {status: 'SUCCESS', message: "an estimation has been calculated", data: {nb_days: params[:nb_days], nb_properties: nb_properties }}, status: 200
    rescue ActiveRecord::RecordNotFound => e
      render json: {status: 'ERROR', message: 'Something went wrong'}, status: 422      
    end
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

  def onboarding_subscriber_params
    params["subscriber"].permit(:firstname, :lastname, :email, :phone, :email_flux, :messenger_flux, :password)
  end

  def onboarding_research_params
    params["research"].permit(:max_price, :min_price, :min_floor, :min_elevator_floor, :has_elevator, :min_surface, :min_rooms_number, :max_sqm_price, :is_active, :balcony, :terrace, :garden, :new_construction, :last_floor, :home_type, :apartment_type)
  end
end
