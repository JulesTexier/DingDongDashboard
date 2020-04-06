require "dotenv/load"
require "typhoeus"
require 'postmark'

class Api::V1::TrelloController < ApplicationController
  protect_from_forgery with: :null_session


  def  send_chatbot_link_from_trello_btn
    document = JSON.parse(request.body.read)
    lead = Lead.where(trello_id_card: document["cardId"])
    render json: {status: 'SUCCESS', message: 'Lead found', data: lead}, status: 500

  end




end
