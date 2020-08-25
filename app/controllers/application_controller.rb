class ApplicationController < ActionController::Base
  protected 

  def after_sign_in_path_for(resource)
    resource.is_a?(Hunter) ? hunter_researches_path(resource) : root_path
  end
end
