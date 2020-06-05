class Api::V1::DataController < ApplicationController
  protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods

  require "dotenv/load"
  TOKEN = ENV["BEARER_TOKEN"]

  before_action :authentificate

  def get_subscribers
    subscribers = Subscriber.all
    render json: { status: "SUCCESS", message: "List of all subscribers", data: subscribers }, status: 200
  end

  def get_active_subscribers
    subscribers = Subscriber.where(is_active: true)
    render json: { status: "SUCCESS", message: "List of all active subscribers", data: subscribers }, status: 200
  end

  def get_facebook_id_subscribers
    subscribers = Subscriber.all
    fb_ids = []
    subscribers.each do |sub|
      fb_ids.push(sub.facebook_id)
    end
    render json: { status: "SUCCESS", message: "List of all active subscribers", data: fb_ids }, status: 200
  end

  def display_shifts
    bs = BrokerShift.all
    @data = []
    bs.each do |doc|
      item = {}
      item[:shift] = doc.name
      item[:brokers] = doc.brokers
      @data.push(item)
    end
  end

  private 
  def authentificate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end
