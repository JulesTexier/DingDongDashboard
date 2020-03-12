class Api::V1::ManychatController < ApplicationController
  protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods

  require "dotenv/load"
  TOKEN = ENV["BEARER_TOKEN"]

  before_action :authentificate

  # POST  (update subscriber) /manychat/s/:subscriber_id/update
  def update_subscriber
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      if subscriber.update(subscriber_params)
        render json: { status: "SUCCESS", message: "Subscriber updated", data: subscriber }, status: 200
      else
        render json: { status: "ERROR", message: "Subscriber not updated", data: nil }, status: 500
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  #GET /manychat/s/:subscriber_id/send/props/last/:x/days
  # Send properties that match Subscriber criteria in the last X days
  def send_props_x_days
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      props = subscriber.get_props_in_lasts_x_days(params[:x])
      props.length > 0 ? (render json: send_multiple_properties(subscriber, props)) : (render json: { status: "ERROR", message: "There is no latest props for this subscriber", data: nil }, status: 404)
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  #GET /manychat/s/:subscriber_id/send/last/:x/props
  # Send X lasts properties that match Subscriber criteria
  def send_x_last_props
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      props = subscriber.get_x_last_props(params[:x])
      props.length > 0 ? (render json: send_multiple_properties(subscriber, props, "last_properties")) : (render json: send_no_props(subscriber, "last_properties"))
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  #GET /subscribers/:subscriber_id/send/props/morning
  # Send properties that match Subscriber criteria during past night
  def send_props_morning
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      subscriber.update(is_active: true)
      props = subscriber.get_morning_props
      props.length > 0 ? (render json: send_multiple_properties(subscriber, props)) : (render json: { status: "ERROR", message: "There is no morning props for this subscriber", data: nil }, status: 404)
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  #GET /subscribers/:subscriber_id/send/props/:property_id/details
  # Send a property details to a subscriber
  def send_prop_details
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      begin
        property = Property.find(params[:property_id])

        m = Manychat.new
        response = m.send_property_info_post_interaction(subscriber, property)
        puts response

        if response[0]
          render json: { status: "SUCCESS", message: "Property sent to subscriber", data: response[1] }, status: 200
        else
          render json: { status: "ERROR", message: "A error occur in manychat call", data: response[1] }, status: 500
        end
      rescue ActiveRecord::RecordNotFound
        render json: { status: "ERROR", message: "Property not found", data: nil }, status: 404
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  #GET /subscribers/:subscriber_id/props/favorites
  # Send properties that match Subscriber criteria during past night
  def send_props_favorites
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      props = subscriber.fav_properties
      render json: send_favorites(subscriber)
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  def authentificate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end

  def send_no_props(subscriber, template = nil)
    m = Manychat.new
    response = m.send_no_props_msg(subscriber, template)
    if response[0]
      return { status: "SUCCESS", message: "No matching props, but a message has been sent to subscriber", data: response[1] }, status: 200
    else
      return { status: "ERROR", message: "A error occur in manychat call", data: response[1] }, status: 500
    end
  end

  def send_multiple_properties(subscriber, properties, template = nil)
    m = Manychat.new
    if !template.nil?
        response = m.send_gallery_properties_card_with_header(template,subscriber, properties)
    else 
        response = m.send_gallery_properties_card(subscriber, properties)
    end
    if response[0]
      return { status: "SUCCESS", message: "#{properties.length} propert(y)(ies) sent to subscriber", data: response[1] }, status: 200
    else
      return { status: "ERROR", message: "A error occur in manychat call", data: response[1] }, status: 500
    end
  end

  def send_favorites(subscriber)
    m = Manychat.new
    response = m.send_favorites_gallery_properties_card(subscriber)
    if response[0]
      return { status: "SUCCESS", message: "#{subscriber.fav_properties.length} propert(y)(ies) sent to subscriber", data: response[1] }, status: 200
    else
      return { status: "ERROR", message: "A error occur in manychat call", data: response[1] }, status: 500
    end
  end

  def subscriber_params
    params.permit(:firstname, :lastname, :email, :phone, :facebook_id, :is_active)
  end
end
