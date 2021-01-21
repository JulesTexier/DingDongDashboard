class StaticController < ApplicationController
  def home
    redirect_to "https://hellodingdong.com"
  end

  def url_not_found

  end
end
