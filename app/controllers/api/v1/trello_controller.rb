require "dotenv/load"
require "typhoeus"

class Api::V1::TrelloController < ApplicationController
  protect_from_forgery with: :null_session

  def initialize
    @trello = Trello.new
  end


  def add_action_to_broker
    document = JSON.parse(request.body.read)
    card_id = document["card_id"]
    comment = document["text"]
    document["mentioned"].downcase == "true" ? mentioned = true : mentioned = false
    !card_id.nil? ? user = Subscriber.where(trello_id_card: card_id).first : user = nil
    
    if !user.nil?
      response = @trello.add_comment_to_user_card(user, comment, mentioned)

      if response.code == 200
        render json: {status: 'SUCCESS', message: 'Action logged into Trello'}, status: 200
      else
        render json: {status: 'ERROR', message: 'Action not logged into Trello'}, status: 503
      end
    else 
      render json: {status: 'ERROR', message: 'No user found for this card_id'}, status: 404 
    end
  end 

  def update_user_broker
    document = JSON.parse(request.body.read)
    user = Subscriber.where(trello_id_card: document["cardId"]).first
    old_card_id = user.trello_id_card
    new_broker = Broker.where(trello_username: document["brokerUsername"]).first
    if !user.nil? && !new_broker.nil?
      # 1 • Update du user avec le nouveau Broker
      user.update(broker: new_broker)
      # 2 • Créer carte dans le tableau du courtier
        is_new_card = @trello.add_new_user_on_trello(user)
      # 3 • Archiver la carte initiale de l'ancien courtier
        is_archive = @trello.archive_card_after_user_transfer(old_card_id, new_broker)

        if is_archive && is_new_card
          render json: {status: 'SUCCESS', message: "User assigned and moved to #{new_broker.firstname}", data: user}, status: 200
        else
          render json: {status: 'ERROR', message: 'User has not been forwarded correctly', data: user}, status: 500
        end
    else
      # b = @trello.get_trello_card_broker(document["cardId"])
      # PostmarkMailer.send_error_message_broker_btn(document["cardId"], b.firstname ).deliver_now
      render json: {status: 'ERROR', message: 'User and/or broker not found !', data: nil}, status: 500
    end
  end


end
