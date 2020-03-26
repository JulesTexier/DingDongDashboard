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
        if params[:message] == "reactivation"
          render json: send_text_message(subscriber, "🔥 Ton alerte a été réactivée !", 'success')
        else
          render json: { status: "SUCCESS", message: "Subscriber updated", data: subscriber }, status: 200
        end
      else
        if params[:message] == "reactivation"
          render json: send_text_message(subscriber, "Oups, un probleme a eu lieu, écris nous directement dans le chat, nous reviendrons vers toi au plus vite!", 'error')
        else
          render json: { status: "ERROR", message: "Subscriber not updated", data: nil }, status: 500
        end
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
      handle_sending(subscriber, props)
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
      handle_sending(subscriber, props)
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
      handle_sending(subscriber, props)
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
      response = send_favorites(subscriber)
      render json: response[:json_response], status: response[:status]
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  private

  def handle_sending(subscriber, props)
    if props.length > 0
      response = send_multiple_properties(subscriber, props)
      render json: response[:json_response], status: response[:status]
    else
      response = send_no_props(subscriber, "morning_properties")
      render json: response[:json_response], status: response[:status]
    end
  end

  def send_no_props(subscriber, template = nil)
    m = Manychat.new
    response = m.send_no_props_msg(subscriber, template)
    if response[0]
      json_response = { status: "SUCCESS", message: "No matching props, but a message has been sent to subscriber", data: response[1] }
      status = 200
    else
      json_response = { status: "ERROR", message: "A error occur in manychat call", data: response[1] }
      status = 406
    end
    return { json_response: json_response.to_json, status: status }
  end

  def send_multiple_properties(subscriber, properties, template = nil)
    m = Manychat.new
    if !template.nil?
      response = m.send_gallery_properties_card_with_header(template, subscriber, properties)
    else
      response = m.send_gallery_properties_card(subscriber, properties)
    end
    if response[0]
      json_response = { status: "SUCCESS", message: "#{properties.length} propert(y)(ies) sent to subscriber", data: response[1] }
      status = 200
    else
      json_response = { status: "ERROR", message: "A error occur in manychat call", data: response[1] }
      status = 406
    end
    return { json_response: json_response.to_json, status: status }
  end

  def send_favorites(subscriber)
    m = Manychat.new
    response = m.send_favorites_gallery_properties_card(subscriber)
    if response[0]
      json_response = { status: "SUCCESS", message: "#{subscriber.fav_properties.length} propert(y)(ies) sent to subscriber", data: response[1] }
      status = 200
    else
      json_response = { status: "ERROR", message: "A error occur in manychat call", data: response[1] }
      status = 406
    end
    return { json_response: json_response.to_json, status: status }
  end

  def send_text_message(subscriber, text, status)
    m = Manychat.new
    response = m.send_text_message(subscriber, text)
    if response[0] && status = 'success'
      return { status: "SUCCESS", message: "Message sent to subscriber", data: response[1] }, status: 200
    elsif response[0] && status = 'error'
      return { status: "ERROR", message: "Bad operation, but a message has been sent to subscriber", data: response[1] }, status: 500
    else
      return { status: "ERROR", message: "A error occur in manychat call, no message sent to subscriber", data: response[1] }, status: 500
    end
  end

  def subscriber_params
    params.permit(:firstname, :lastname, :email, :phone, :is_active)
  end

  def authentificate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end

