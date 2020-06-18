class HunterSearchesController < ApplicationController
  before_action :find_hunter_and_search, except: [:index, :new, :create]

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
  end

  def create
    @hunter = Hunter.find(params[:hunter_id])
    @hunter_search = @hunter.hunter_searches.build(hunter_search_params)
    if @hunter_search.save
      redirect_to hunter_hunter_search_path(@hunter, @hunter_search)
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @hunter_search.update(hunter_search_params)
      redirect_to hunter_hunter_search_path(@hunter, @hunter_search)
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

  def hunter_search_params
    params.require(:hunter_search).permit(:research_name, :min_floor, :has_elevator, :min_elevator_floor, :surface, :rooms_number, :max_price, :areas => [])
  end
end
