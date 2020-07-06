class HunterSearchesController < ApplicationController
  before_action :authenticate_hunter!
  before_action :find_hunter_and_search, except: [:index, :new, :create]

  def index
    @hunter = current_hunter
    @hunter_searches = HunterSearch.where(hunter: @hunter)
  end

  def show
    @properties = @hunter_search.get_matching_properties(18)
    @selected_properties = HunterSearch.find(params[:id]).properties.pluck(:id)
  end

  def new
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = @hunter.hunter_searches.build

    hs_areas_id = @hunter_search.areas.pluck(:id)
    zone_areas = ["Paris", "Première Couronne"]
    @paris_areas = []
    @premiere_couronne_areas = []
    Area.where(zone: "Paris").order(:id).pluck(:id, :name).each do |item|
      selected = hs_areas_id.include?(item[0]) ? "selected" : ""
      item.push(selected)
      @paris_areas.push(item)
    end
    Area.where(zone: "Première Couronne").order(:id).pluck(:id, :name).each do |item|
      selected = hs_areas_id.include?(item[0]) ? "selected" : ""
      item.push(selected)
      @premiere_couronne_areas.push(item)
    end
  end

  def create
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = @hunter.hunter_searches.build(hunter_search_params)
    if @hunter_search.save
      areas_name = []
      areas_name += params[:paris_areas] if !params[:paris_areas].nil?
      areas_name += params[:premiere_couronne_areas] if !params[:premiere_couronne_areas].nil?
      @hunter_search.areas << Area.where(id: areas_name)
      redirect_to hunter_hunter_search_path(@hunter, @hunter_search)
    else
      render "new"
    end
  end

  def edit
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = HunterSearch.find(params[:id])
    @areas = Area.get_active
    @hs_areas = @hunter_search.areas.pluck(:id)
    
    hs_areas_id = @hunter_search.areas.pluck(:id)
    zone_areas = ["Paris", "Première Couronne"]
    @paris_areas = []
    @premiere_couronne_areas = []
    Area.where(zone: "Paris").order(:id).pluck(:id, :name).each do |item|
      selected = hs_areas_id.include?(item[0]) ? "selected" : ""
      item.push(selected)
      @paris_areas.push(item)
    end
    Area.where(zone: "Première Couronne").order(:id).pluck(:id, :name).each do |item|
      selected = hs_areas_id.include?(item[0]) ? "selected" : ""
      item.push(selected)
      @premiere_couronne_areas.push(item)
    end
  end

  def update
    if @hunter_search.update(hunter_search_params)
      areas_name = []
      areas_name += params[:paris_areas] if !params[:paris_areas].nil?
      areas_name += params[:premiere_couronne_areas] if !params[:premiere_couronne_areas].nil?
      
      if !areas_name.empty?
        @hunter_search.areas.destroy_all 
        @hunter_search.areas << Area.where(id: areas_name)
      end
      respond_to do |format|
        format.html { redirect_to hunter_hunter_search_path(@hunter, @hunter_search) } 
        format.js { redirect_to hunter_hunter_searches_path(@hunter) }
        format.xml { head :ok }
      end
    else
      render "edit"
    end
  end

  def destroy
    Selection.where(hunter_search: @hunter_search).destroy_all
    @hunter_search.destroy
    respond_to do |format|
      format.html { redirect_to hunter_hunter_searches_path }
      format.xml { head :ok }
    end
  end

  private

  def find_hunter_and_search
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = HunterSearch.find(params[:id])
  end

  def hunter_search_params
    params.require(:hunter_search).permit(:research_name, :min_floor, :has_elevator, :min_elevator_floor, :min_surface, :min_rooms_number, :max_price, :min_price, :max_sqm_price, :is_active, :balcony, :terrace, :garden, :last_floor, :new_construction)
  end
end
