require "dotenv/load"

class Api::V1::ManychatController < ApplicationController
  TOKEN = ENV["BEARER_TOKEN"]
  protect_from_forgery with: :null_session
  before_action :authentificate

  include ActionController::HttpAuthentication::Token::ControllerMethods

  # POST : Create SubscriberStatus
  def create_subscriber_status
    subscriber = Subscriber.find(params[:subscriber_id])
    status = Status.find_by(name: params[:status_name])

    if !subscriber.nil? && !status.nil?
      ss = SubscriberStatus.create(subscriber: subscriber, status: status)
      render json: { status: "SUCCESS", message: "SubscriberStatus created", data: ss }, status: 200
    else
      render json: { status: "ERROR", message: "subscriber or status not found", data: nil }, status: 500
    end
  end

  # POST  (update subscriber) /manychat/s/:subscriber_id/update
  def update_subscriber
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      if subscriber.update(subscriber_params.except(:subscriber_id, :message))
        if subscriber_params[:message] == "reactivation"
          SubscriberNote.create(subscriber: subscriber, content: "Alerte réactivée après inactivité")
          if subscriber.broker.nil?
            render json: send_flow_sequence(subscriber, "content20200511081309_374734")
          else
            render json: send_text_message(subscriber, "🔥 Votre alerte a été réactivée !", "success")
          end
        else
          data = subscriber.as_json
          data[:areas_list] = subscriber.get_areas_list
          data[:edit_path] = subscriber.get_edit_path
          render json: { status: "SUCCESS", message: "Subscriber updated", data: data }, status: 200
        end
      else
        if subscriber_params[:message] == "reactivation"
          render json: send_text_message(subscriber, "Oups, un probleme a eu lieu, écris nous directement dans le chat, nous reviendrons vers toi au plus vite!", "error")
        else
          render json: { status: "ERROR", message: "Subscriber not updated", data: nil }, status: 500
        end
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  # GET /manychat/s/:subscriber_id/send/props/last/:x/days
  # Send properties that match Subscriber criteria in the last X days
  def send_props_x_days
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      props_ids = subscriber.research.properties_last_x_days(params[:x])
      handle_sending(subscriber, props_ids)
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  # GET /manychat/s/:subscriber_id/send/last/:x/props
  # Send X lasts properties that match Subscriber criteria unless user is blocked
  def send_x_last_props
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      if subscriber.is_blocked
        send_flow(subscriber, "content20200604125739_572289")
      else
        props_ids = subscriber.research.last_x_properties(params[:x])
        handle_sending(subscriber, props_ids.reverse, "last_properties")
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  # GET /subscribers/:subscriber_id/send/props/morning
  # Send properties that match Subscriber criteria during past night
  def send_props_morning
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      subscriber.update(is_active: true)
      props_ids = subscriber.research.morning_properties
      handle_sending(subscriber, props_ids, "morning_properties")
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Subscriber not found", data: nil }, status: 404
    end
  end

  # GET /subscribers/:subscriber_id/send/props/:property_id/details
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

  # GET /subscribers/:subscriber_id/props/favorites
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

  def handle_sending(subscriber, props_ids, template = nil)
    props = Property.where(id: props_ids)
    if props.length > 0
      response = send_multiple_properties(subscriber, props, template)
      render json: response[:json_response], status: response[:status]
    else
      response = send_no_props(subscriber, template)
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
    response = m.send_properties_gallery(subscriber, properties, template)

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

  def send_flow(subscriber, flow)
    m = Manychat.new
    response = m.send_flow_sequence(subscriber, flow)
    if response[0]
      json_response = { status: "SUCCESS", message: "The flow #{flow} has been sent to the subscriber #{subscriber.id}", data: response[1] }
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
    if response[0] && status == "success"
      return { status: "SUCCESS", message: "Message sent to subscriber", data: response[1] }, status: 200
    elsif response[0] && status == "error"
      return { status: "ERROR", message: "Bad operation, but a message has been sent to subscriber", data: response[1] }, status: 500
    else
      return { status: "ERROR", message: "A error occur in manychat call, no message sent to subscriber", data: response[1] }, status: 500
    end
  end

  def subscriber_params
    params.permit(:firstname, :lastname, :email, :phone, :is_active, :subscriber_id, :message, :facebook_id, :status, :is_blocked, :messenger_flux, :email_flux, :broker_id, :notary_id, :contractor_id)
  end

  def authentificate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end
