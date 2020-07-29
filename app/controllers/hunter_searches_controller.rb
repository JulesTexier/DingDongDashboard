class HunterSearchesController < ApplicationController
  before_action :authenticate_hunter!
  before_action :find_hunter_and_search, except: [:index, :new, :create]

  def index
    @hunter = current_hunter
    @hunter_searches = Research.where(hunter: @hunter)
  end

  def show
    @properties = @hunter_search.last_matching_properties(100)
    # @selected_properties = Research.find(params[:id]).properties.pluck(:id)
  end

  def new
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = @hunter.researches.build

    hs_areas_id = @hunter_search.areas.pluck(:id)
    @master_areas = Area.get_areas_for_hunters(hs_areas_id)
  end

  def create
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = @hunter.researches.build(hunter_search_params)
    if @hunter_search.save
      areas_ids = params[:area_ids]
      @hunter_search.areas << Area.where(id: areas_ids)
      redirect_to hunter_research_path(@hunter, @hunter_search)
    else
      render "new"
    end
  end

  def edit
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = Research.find(params[:id])
    @areas = Area.get_active
    @hs_areas = @hunter_search.areas.pluck(:id)    
    hs_areas_id = @hunter_search.areas.pluck(:id)
    @master_areas = Area.get_areas_for_hunters(hs_areas_id)
  end

  def update
    if @hunter_search.update(hunter_search_params)
      areas_ids = params[:area_ids] 
      
      if !areas_ids.empty?
        @hunter_search.update_research_areas(areas_ids)
      end
      respond_to do |format|
        format.html { redirect_to hunter_research_path(@hunter, @hunter_search) } 
        format.js { redirect_to hunter_researches_path(@hunter) }
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
    @hunter_search = Research.find(params[:id])
  end

  def hunter_search_params
    params.require(:research).permit(:name, :zone, :min_floor, :has_elevator, :min_elevator_floor, :min_surface, :min_rooms_number, :max_price, :min_price, :max_sqm_price, :is_active, :balcony, :terrace, :garden, :last_floor, :new_construction)
  end
end
