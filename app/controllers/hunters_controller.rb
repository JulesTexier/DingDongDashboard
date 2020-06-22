class HuntersController < ApplicationController
  before_filter :authenticate_hunter!

  protected

  def after_sign_in_path_for(resource)
    hunter_hunter_searches_path(resource)
  end
end
