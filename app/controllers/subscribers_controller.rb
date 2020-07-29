class SubscribersController < ApplicationController  
  # ###############
  #      CRUD     #
  # ###############

  def edit
    @subscriber = Subscriber.find(params[:id])
    subscriber_areas_id = @subscriber.areas.pluck(:id)
    if params[:selected_zones].nil? && subscriber_areas_id.empty?
      flash[:danger] = "Veuillez sélectionner une zone de recherche."
      redirect_to "/subscribers/" + params[:id] + "/agglomeration"
    elsif subscriber_areas_id.any?
      zone = @subscriber.determine_zone
      @master_areas = Area.get_selected_agglo_area(zone[0], subscriber_areas_id)
      @master_areas += Area.global_zones(zone[0])
    else
      @master_areas = Area.get_selected_agglo_area(params[:selected_zones], subscriber_areas_id)
      @master_areas += Area.global_zones(params[:selected_zones])
    end
  end

  def update
    @subscriber = Subscriber.find(params[:id])
    @research = @subscriber.research
    areas_ids = []
    areas_ids += params[:areas] unless params[:areas].nil?
    if @subscriber.update(research_params) && !areas_ids.empty?
      @research.update_research_areas(areas_ids)
      flash[:success] = "Les critères sont enregistrés ! Fermez cette fenêtre pour continuer."
    else
      flash[:danger] = "Sélectionnez des arrondissements..."
    end
    # // Send flow to subscriber 
    flow = "content20200716131717_882877"
    Manychat.new.send_flow_sequence(@subscriber, flow) unless Rails.env.development?
    redirect_to edit_subscriber_path
  end

  # ###############
  #      OTHER    #
  # ###############


  def select_agglomeration
    @subscriber = Subscriber.find(params[:subscriber_id])
    @agglos_infos = Area.get_agglo_infos
  end
  
  
  def activation
    flow = "content20200716090652_490399"

    @subscriber = Subscriber.find(params[:subscriber_id])
    if !@subscriber.nil?
      @subscriber.update(is_blocked: false) 
      SubscriberStatus.create(subscriber: @subscriber, status: Status.find_by(name: "unblocked"))
      Manychat.new.send_flow_sequence(@subscriber, flow)
    end
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :has_messenger, :facebook_id)
  end

  def research_params
    params.require(:research).permit(:max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor, :project_type, :additional_question, :specific_criteria, :broker_id, :status, :initial_areas, :terrace, :garden, :balcony, :new_construction, :last_floor, :min_price, :max_sqm_price)
  end
end
