require "dotenv/load"
require "typhoeus"

class Api::V1::TrelloController < ApplicationController
  protect_from_forgery with: :null_session


  def  send_chatbot_link_from_trello_btn
    document = JSON.parse(request.body.read)
    byebug
    lead = Lead.where(trello_id_card: document["cardId"]).first

    PostmarkMailer.send_chatbot_link(lead).deliver_now

    # client = Postmark::ApiClient.new(ENV['POSTMARK_TOKEN'])
    # client.deliver_with_template(
    #   {:from=>"greg@hellodingdong.com",
    #  :to=>lead.email,
    #  :template_alias=>"welcome",
    #  :template_model=>
    #   {"name"=>lead.name,
    #    "action_url"=>chatbot_link,
    #    "broker_phone"=>lead.broker.phone,
    #    "broker_email"=>lead.broker.email}}
    # )

    render json: {status: 'SUCCESS', message: 'Lead found'}, status: 500
  end




end
