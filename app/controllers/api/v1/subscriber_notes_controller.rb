require 'dotenv/load'

class Api::V1::SubscriberNotesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  TOKEN = ENV['BEARER_TOKEN']
  protect_from_forgery with: :null_session
  before_action :authentificate

   def create 
        subscriber_note = SubscriberNote.new(subscriber_note_params)
        if subscriber_note.save
            render json: {status: 'SUCCESS', message: 'Subscriber note created', data: subscriber_note}, status: 200
        else
            render json: {status: 'ERROR', message: 'Subscriber note could not be created', data: subscriber_note.errors}, status: 500
        end
    end

  private
  def authentificate
      authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
  end

  def subscriber_note_params
    params.permit(:content, :subscriber_id)
  end
end
