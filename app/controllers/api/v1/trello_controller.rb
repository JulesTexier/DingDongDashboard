require "dotenv/load"
require "typhoeus"

class Api::V1::TrelloController < ApplicationController
  protect_from_forgery with: :null_session

  TRELLO_AUTH = "key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_SECRET']}"


  def send_chatbot_link_from_trello_btn
    document = JSON.parse(request.body.read)
    lead = Lead.where(trello_id_card: document["cardId"]).first

    if !lead.nil?
      PostmarkMailer.send_chatbot_link(lead).deliver_now
      lead.update(status: 'chatbot_invite_sent')
      render json: {status: 'SUCCESS', message: 'Lead found', data: lead}, status: 200
    else
      
      request = Typhoeus::Request.new(
        "https://api.trello.com/1/cards/#{document["cardId"]}/members?" + TRELLO_AUTH,
        method: :get
      )
      response = request.run
      byebug
      broker_trello_id = JSON.parse(response.body)[0]["id"]
      b = Broker.where(trello_id: broker_trello_id).first
      PostmarkMailer.send_error_message_broker_btn(document["cardId"], b.firstname ).deliver_now
      render json: {status: 'ERROR', message: 'Lead not found, email sent to Etienne with data about the concerned broker', data: b}, status: 500
    end
  end

  def add_action_to_broker
    document = JSON.parse(request.body.read)
    card_id = document["card_id"]
    text = document["text"]
    lead = Lead.where(trello_id_card: card_id).first
    
    if !lead.nil?
      # Add comment to the card mentioning the broker
      check_items_params = {}
      check_items_params[:text] = text + " @#{lead.broker.trello_username}"
      request = Typhoeus::Request.new(
        "https://api.trello.com/1/cards/#{card_id}/actions/comments?" + TRELLO_AUTH,
        method: :post,
        params: check_items_params
      )
      response = request.run

      if response.code == 200
        render json: {status: 'SUCCESS', message: 'Action logged into Trello'}, status: 200
      else
        render json: {status: 'ERROR', message: 'Action not logged into Trello'}, status: 503
      end
    else 
      render json: {status: 'ERROR', message: 'No lead found for this card_id'}, status: 404 
    end
  end 
end