class HunterSearchesController < ApplicationController
  before_action :find_hunter_and_search, except: [:index, :new, :create]
  before_action :check_current_hunter

  def index
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_searches = HunterSearch.where(hunter_id: params[:hunter_id])
  end

  def show
    @properties = @hunter_search.get_matching_properties
  end

  def new
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = @hunter.hunter_searches.build
    @areas = Area.get_active
    @hs_areas = []
  end

  def create
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = @hunter.hunter_searches.build(hunter_search_params)
    if @hunter_search.save
      @hunter_search.areas << Area.where(id: params["hunter_search"]["areas"])
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
  end

  def update
    if @hunter_search.update(hunter_search_params)
      @hunter_search.areas.destroy_all
      @hunter_search.areas << Area.where(id: params["hunter_search"]["areas"])
      redirect_to hunter_hunter_search_path(@hunter, @hunter_search)
      # redirect_to edit_hunter_hunter_search_path(@hunter, @hunter_search)
    else
      render "edit"
    end
  end

  def destroy
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

  def check_current_hunter
    hunter = Hunter.find_by(id: params[:hunter_id])
    if hunter.nil? || hunter != current_hunter
      redirect_to hunter_hunter_searches_path(current_hunter.id)
    end
  end

  def hunter_search_params
    params.require(:hunter_search).permit(:research_name, :min_floor, :has_elevator, :min_elevator_floor, :surface, :rooms_number, :max_price)
  end
end
