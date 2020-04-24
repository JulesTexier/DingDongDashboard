class Api::V1::WebhooksController < ApplicationController

  protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods


  def handle_postmark_inbound
    render json: { status: "SUCCESS", message: "Hello"}, status: 200
  end

end
