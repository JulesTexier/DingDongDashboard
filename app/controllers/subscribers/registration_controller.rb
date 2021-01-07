module Subscribers
  class RegistrationController < ApiGuard::RegistrationController
    # before_action :authenticate_resource, only: [:destroy]

    def create
      resource = Subscriber.where(email: sign_up_params[:email]).last
      
      if resource.nil? 
        resource = init_resource(sign_up_params)
      else
        alt_sub = init_resource(sign_up_params)
        resource.password = alt_sub.password
        resource.password_confirmation = alt_sub.password_confirmation
      end 

      if resource.save
        create_token_and_set_header(resource, resource_name)
        render_success(message: I18n.t('api_guard.registration.signed_up'))
      else
        render_error(422, object: resource)
      end
    end

    # def destroy
    #   current_resource.destroy
    #   render_success(message: I18n.t('api_guard.registration.account_deleted'))
    # end

    private

    def sign_up_params
      params.require(:registration).permit(:email, :password, :password_confirmation)
    end
  end
end
