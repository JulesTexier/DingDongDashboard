class SelectionsController < ApplicationController
  def index
    @properties = HunterSearch.find(params["hunter_search_id"]).properties
  end

  def create
    Selection.create(hunter_search_id: params['hunter_search_id'], property_id: params['property_id'])
  end

  def destroy
  end
end
