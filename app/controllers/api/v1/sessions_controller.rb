# File app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [:create ]

  # /api/v1/sign_in.json
  def create
    byebug
    resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)

    render json: {:success => true, auth_token: current_user.authentication_token }.to_json, status: :200
  end

  # /api/v1/sign_out.json
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    render json: {:success => true, auth_token: nil }.to_json, status: :200
  end
  
  def failure
    render :json => {:success => false, :errors => ["Login Failed"]}, status: 401
  end
protected
  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#failure" }
  end
end