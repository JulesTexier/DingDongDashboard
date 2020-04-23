require "dotenv/load"
require "typhoeus"

class Api::V1::TrelloController < ApplicationController
  protect_from_forgery with: :null_session

  def initialize
    @trello = Trello.new
  end

  def send_chatbot_link_from_trello_btn
    document = JSON.parse(request.body.read)
    lead = Lead.where(trello_id_card: document["cardId"]).first

    if !lead.nil?
      PostmarkMailer.send_chatbot_link(lead).deliver_now
      lead.update(status: 'chatbot_invite_sent')
      render json: {status: 'SUCCESS', message: 'Lead found', data: lead}, status: 200
    else
      b = @trello.get_trello_card_broker(document["cardId"])
      PostmarkMailer.send_error_message_broker_btn(document["cardId"], b.firstname ).deliver_now
      render json: {status: 'ERROR', message: 'Lead not found, email sent to Etienne with data about the concerned broker', data: b}, status: 500
    end
  end

  def add_action_to_broker
    document = JSON.parse(request.body.read)
    card_id = document["card_id"]
    comment = document["text"]
    !card_id.nil? ? lead = Lead.where(trello_id_card: card_id).first : lead = nil
    
    if !lead.nil?
      response = @trello.add_comment_to_lead_card(lead, comment)

      if response.code == 200
        render json: {status: 'SUCCESS', message: 'Action logged into Trello'}, status: 200
      else
        render json: {status: 'ERROR', message: 'Action not logged into Trello'}, status: 503
      end
    else 
      render json: {status: 'ERROR', message: 'No lead found for this card_id'}, status: 404 
    end
  end 

  def update_lead_broker
    document = JSON.parse(request.body.read)
    lead = Lead.where(trello_id_card: document["cardId"]).first
    old_card_id = lead.trello_id_card
    new_broker = Broker.where(trello_username: document["brokerUsername"]).first
    if !lead.nil? && !new_broker.nil?
      # 1 • Update du lead avec le nouveau Broker
        lead.update(broker: new_broker)
      # 2 • Créer carte dans le tableau du courtier
        is_new_card = @trello.add_new_lead_on_trello(lead)
      # 3 • Archiver la carte initiale de l'ancien courtier
        is_archive = @trello.archive_card_after_lead_transfer(old_card_id, new_broker)

        if is_archive && is_new_card
          render json: {status: 'SUCCESS', message: "Lead assigned and moved to #{new_broker.firstname}", data: lead}, status: 200
        else
          render json: {status: 'ERROR', message: 'Lead has not been transfered correctly', data: lead}, status: 500
        end
    else
      # b = @trello.get_trello_card_broker(document["cardId"])
      # PostmarkMailer.send_error_message_broker_btn(document["cardId"], b.firstname ).deliver_now
      render json: {status: 'ERROR', message: 'Lead and/or broker not found !', data: nil}, status: 500
    end
  end

end
