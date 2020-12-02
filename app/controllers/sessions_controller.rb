class SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session
  before_action :set_default_response_format

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?
    @token = current_token
    render json:{'token': @token }
  end

  def show
    if broker_signed_in?
      render json:  {user: current_broker }, status: 200
    else
      render json: {status: 'ERROR', message: 'Broker not found'}, status: 406
    end
  end

  private

  def current_token
    request.env['warden-jwt_auth.token']
  end

  def set_default_response_format
    request.format = :json
  end

end