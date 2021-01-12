module Subscribers
  class AuthenticationController < ApiGuard::AuthenticationController
    # before_action :find_resource, only: [:create]
    # before_action :authenticate_resource, only: [:destroy]

    def create
      if subscriber = params[:password].nil? ? Subscriber.get_by_auth_token(params[:auth_token]) : resource.authenticate(params[:password])
        create_token_and_set_header(subscriber, resource_name)
        render json: {message: I18n.t('api_guard.authentication.signed_in'), token: response.header["Access-Token"] }, status: 200
      else
        render_error(422, message: I18n.t('api_guard.authentication.invalid_login_credentials'))
      end
    end

    # def destroy
    #   blacklist_token
    #   render_success(message: I18n.t('api_guard.authentication.signed_out'))
    # end

    # private

    # def find_resource
    #   self.resource = resource_class.find_by(email: params[:email].downcase.strip) if params[:email].present?
    #   render_error(422, message: I18n.t('api_guard.authentication.invalid_login_credentials')) unless resource
    # end
  end
end
