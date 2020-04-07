require "dotenv/load"
require "typhoeus"

class Api::V1::TrelloController < ApplicationController
  protect_from_forgery with: :null_session


  def  send_chatbot_link_from_trello_btn
    document = JSON.parse(request.body.read)
    lead = Lead.where(trello_id_card: document["cardId"]).first

    if !lead.nil?
      PostmarkMailer.send_chatbot_link(lead).deliver_now
      lead.update(status: 'chatbot_invite_sent')
      render json: {status: 'SUCCESS', message: 'Lead found', data: lead}, status: 200
    else
      trello_auth = "key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_SECRET']}"
      request = Typhoeus::Request.new(
        "https://api.trello.com/1/cards/#{document["cardId"]}/members?" + trello_auth,
        method: :get
      )
      response = request.run
      broker_trello_id = JSON.parse(response.body)[0]["id"]
      b = Broker.where(trello_id: broker_trello_id).first
      PostmarkMailer.send_error_message_broker_btn(document["cardId"], b.firstname ).deliver_now
      render json: {status: 'ERROR', message: 'Lead not found, email sent to Etienne with data about the concerned broker', data: b}, status: 500
    end
  end




end
