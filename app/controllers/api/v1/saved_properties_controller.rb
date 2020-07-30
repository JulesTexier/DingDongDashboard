class Api::V1::SavedPropertiesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  TOKEN = ENV['BEARER_TOKEN']
  protect_from_forgery with: :null_session
  before_action :authentificate

  # POST /favorites/
  def create 
      begin
        saved_property = Favorite.new(saved_property_params)
        s = Research.find(params[:research_id]).subscriber
        if fav.save
            render json: send_message_post_add(s, "success")
          else
            if fav.errors.messages[:subscriber][0] === "has already been taken" 
                render json: send_message_post_add(s, "error_already_exists")
            else
                render json: send_message_post_add(s, "error")
            end
          end
      rescue ActiveRecord::RecordNotFound
        render json: {status: 'ERROR', message: 'Subcriber not found', data: nil}, status: 404
      end
  end

  # DELETE /subscribers/:id
  def destroy 
    begin
      fav = Favorite.find(params[:id])
      s = fav.subscriber
      if fav.destroy
        render json: send_message_post_delete(s, "success")
      else
        render json: send_message_post_delete(s, "error")
      end
    rescue ActiveRecord::RecordNotFound
      render json: {status: 'ERROR', message: 'Favorite not found', data: nil}, status: 404
    end
  end

  private
  def authentificate
    authenticate_or_request_with_http_token do |token, options|
      ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
    end
  end

  def saved_property_params
    params.permit(:research_id, :property_id)
  end

  def send_message_post_add(s, msg)
    m = Manychat.new
    if msg == "success"
      response = m.send_message_post_fav_added(s, msg)
      if response[0]
          return {status: 'SUCCESS', message: "Favorite has been created and a message has been sent to subscriber", data: response[1]}, status: 200
      else 
          return {status: 'ERROR', message: 'Favorite has been created but the message could not been sent to subscriber !', data: response[1]}, status: 500
      end
    else 
      response = m.send_message_post_fav_added(s, msg)
      if response[0]
          return {status: 'ERROR', message: "Favorite has not been created but a message has been sent to subscriber", data: response[1]}, status: 500
      else 
          return {status: 'ERROR', message: 'Favorite has not been created but the message could not been sent to subscriber !', data: response[1]}, status: 500
      end
    end        
  end

  def send_message_post_delete(s, msg)
    m = Manychat.new
    if msg == "success"
      response = m.send_message_post_fav_deleted(s, msg)
      if response[0]
          return {status: 'SUCCESS', message: "Favorite has been deleted and a message has been sent to subscriber", data: response[1]}, status: 200
      else 
          return {status: 'ERROR', message: 'Favorite has been deleted but the message could not been sent to subscriber !', data: response[1]}, status: 500
      end
    else 
      response = m.send_message_post_fav_deleted(s, msg)
      if response[0]
        return {status: 'ERROR', message: "Favorite has not been deleted but a message has been sent to subscriber", data: response[1]}, status: 500
      else 
        return {status: 'ERROR', message: 'Favorite has not been deleted but the message could not been sent to subscriber !', data: response[1]}, status: 500
      end
    end        
  end
end
