require "dotenv/load"
require "typhoeus"
require 'postmark-rails'

class Api::V1::TrelloController < ApplicationController
  protect_from_forgery with: :null_session


  def  send_chatbot_link_from_trello_btn
    document = JSON.parse(request.body.read)
    lead = Lead.where(trello_id_card: document["cardId"])

    client = Postmark::ApiClient.new(ENV['POSTMARK_API'])
    client.deliver_with_template(
      {:from=>"greg@hellodingdong.com",
     :to=>lead.email,
     :template_alias=>"welcome",
     :template_model=>
      {"name"=>lead.name,
       "action_url"=>chatbot_link,
       "broker_phone"=>lead.broker.phone,
       "broker_email"=>lead.broker.email}}
    )

    render json: {status: 'SUCCESS', message: 'Lead found', data: lead}, status: 500
  end




end
