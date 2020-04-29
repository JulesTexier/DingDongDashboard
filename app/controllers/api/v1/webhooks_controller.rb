class Api::V1::WebhooksController < ApplicationController

  protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods


  def handle_postmark_inbound
    if params["FromName"] == "SeLoger"
      if params["Subject"].match(/(\d){1,}(\s)(annonce)/i).is_a?(MatchData)
        Email::ScraperSeLogerMultiple.new(params["HtmlBody"]).launch
      else 
        Email::ScraperSeLogerSingle.new(params["HtmlBody"]).launch
      end
      # Gérer des condtitions pour savoir si on a bien inséré la property ou pas ... (doublon, 500 ou succès) 
      render json: { status: "SUCCESS", message: "Mail from SeLoger", data: nil}, status: 200
    elsif params["FromName"] == "Postmarkapp Support"
      render json: { status: "SUCCESS", message: "Mail from PostMark Support", data: nil}, status: 200
    else 
      render json: { status: "ERROR", message: "Can't handle this email"}, status: 500
    end
  end

end
