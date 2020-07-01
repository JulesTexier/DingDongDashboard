class SelectionsController < ApplicationController
  def index
    @hunter_search = HunterSearch.find(params["hunter_search_id"])
    @data = []
    selections = Selection.where(hunter_search_id: params["hunter_search_id"])
    selections.each do |selection|
      @data.push([selection.id, selection.property])
    end
    # @properties = HunterSearch.find(params["hunter_search_id"]).properties
  end

  def create
    Selection.create(hunter_search_id: params['hunter_search_id'], property_id: params['property_id'])
  end

  def destroy
    Selection.find(params[:id]).destroy
  end
end
