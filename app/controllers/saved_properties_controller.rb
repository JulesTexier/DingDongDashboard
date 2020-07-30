class SavedPropertiesController < ApplicationController
  def index
    @hunter_search = Research.find(params[:research_id])
    @data = []
    saved_properties = SavedProperty.where(research_id: params[:research_id])
    saved_properties.each do |saved_property|
      @data.push([saved_property.id, saved_property.property])
    end
  end

  def create
    SavedProperty.create(research_id: params[:research_id], property_id: params[:property_id])
  end

  def destroy
    SavedProperty.find(params[:id]).destroy
    respond_to do |format|
      format.js { redirect_to hunter_research_saved_properties_path(params[:hunter_id], params[:research_id]) }
    end
  end
end
