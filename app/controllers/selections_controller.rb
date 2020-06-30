class SelectionsController < ApplicationController
  def index
  end

  def create
    Selection.create(hunter_search_id: params['hunter_search_id'], property_id: params['property_id'])
  end

  def destroy
  end
end
