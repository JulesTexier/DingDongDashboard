class Api::V1::WebhooksController < ApplicationController

  protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods


  def handle_postmark_inbound
    if params["FromName"] == "SeLoger"
      Email::ScraperSeLoger.new(params["HtmlBody"]).launch
      # Gérer des condtitions pour savoir si on a bien inséré la property ou pas ... (doublon, 500 ou succès) 
      render json: { status: "SUCCESS", message: "Mail from SeLoger", data: nil}, status: 200
    else 
      render json: { status: "ERROR", message: "Can't handle this email"}, status: 500
    end
  end

end
