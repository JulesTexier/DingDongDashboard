class Api::V1::ManychatController < ApplicationController
  protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods

  require "dotenv/load"
  TOKEN = ENV["BEARER_TOKEN"]

  before_action :authentificate

  #POST (create subscriber in manychat) /manychat/s/create-from-lead
  def create_subscriber_from_lead
    lead = Lead.find(params[:lead_id])

    if !lead.nil?
      subscriber_hash = {}
      subscriber_hash[:firstname] = lead.firstname
      subscriber_hash[:lastname] = lead.lastname
      subscriber_hash[:email] = lead.email
      subscriber_hash[:phone] = lead.phone
      subscriber_hash[:min_surface] = lead.min_surface
      subscriber_hash[:max_price] = lead.max_price
      subscriber_hash[:min_rooms_number] = lead.min_rooms_number
      subscriber_hash[:broker_id] = lead.broker_id
      subscriber_hash[:trello_id_card] = lead.trello_id_card
      subscriber_hash[:facebook_id] = params[:facebook_id]
      subscriber_hash[:status] = "onboarding_started"
      subscriber_hash[:is_active] = true
      s = Subscriber.new(subscriber_hash)

      if s.save
        lead.areas.split(",").each do |area|
          area = Area.where(name: area).first
          SelectedArea.create(subscriber: s, area: area) if !area.nil?
        end

        data = s.as_json
        data[:areas_list] = s.get_areas_list
        data[:districts_list] = s.get_districts_list
        data[:edit_path] = s.get_edit_path
        data[:project_type] = lead.project_type
        render json: { status: "SUCCESS", message: "Subscriber created", data: data }, status: 200
      else
        render json: { status: "ERROR", message: "Subscriber not created", data: nil }, status: 500
      end
    else
      render json: { status: "ERROR", message: "Lead not found", data: nil }, status: 404
    end
  end

  # POST  (update subscriber) /manychat/s/:subscriber_id/update
  def update_subscriber
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      if subscriber.update(subscriber_params.except(:subscriber_id, :message))
        if subscriber_params[:message] == "reactivation"
          if subscriber.broker.nil?
            render json: send_flow_sequence(subscriber, "content20200511081309_374734")
          else
            render json: send_text_message(subscriber, "🔥 Votre alerte a été réactivée !", "success")
          end
        else
          data = subscriber.as_json
          data[:areas_list] = subscriber.get_areas_list
          data[:districts_list] = subscriber.get_districts_list
          data[:edit_path] = subscriber.get_edit_path
          data[:project_type] = subscriber.project_type
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

  # POST  (update lead) /manychat/l/:lead_id/update
  def update_lead
    begin
      lead = Lead.find(params[:lead_id])
      if lead.update(lead_params.except(:lead_id))
        render json: { status: "SUCCESS", message: "Lead updated", data: lead }, status: 200
      else
        render json: { status: "ERROR", message: "Lead not updated", data: nil }, status: 500
      end
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "Lead not found", data: nil }, status: 404
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
      handle_sending(subscriber, props, "last_properties")
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
      handle_sending(subscriber, props, "morning_properties")
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

  # POST "/manychat/s/:subscriber_id/onboard_broker"
  # One click btn to atatch user to broker
  def onboard_old_users
    begin
      subscriber = Subscriber.find(params[:subscriber_id])
      subscriber.onboarding_old_user
      render json: { status: "SUCCESS", message: "Subscriber added to #{subscriber.broker.firstname}'s Trello", data: subscriber }, status: 200
    rescue ActiveRecord::RecordNotFound
      render json: { status: "ERROR", message: "An error occurred", data: nil }, status: 500
    end
  end

  private

  def handle_sending(subscriber, props, template = nil)
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
    # params.permit(:firstname, :lastname, :email, :phone, :is_active)
    params.permit(:firstname, :lastname, :email, :phone, :is_active, :subscriber_id, :message, :facebook_id, :status)
  end

  def lead_params
    params.permit(:id, :name, :email, :phone, :status, :broker_id, :lead_id)
  end

  def authentificate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end
end
