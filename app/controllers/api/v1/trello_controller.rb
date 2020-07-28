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

end
