class SubscribersController < ApplicationController
  
  # ###############
  # CRUD 
  # ###############
  def edit
    @subscriber = Subscriber.find(params[:id])
    subscriber_areas_id = @subscriber.areas.pluck(:id)
    @master_areas = Area.get_aggregate_data_for_selection(subscriber_areas_id)
  end

  def update
    @subscriber = Subscriber.find(params[:id])
    areas_ids = []
    areas_ids += params[:paris_areas] if !params[:paris_areas].nil?
    areas_ids += params[:premiere_couronne_areas] if !params[:premiere_couronne_areas].nil?
    if @subscriber.update(subscriber_params) && !areas_ids.empty?
      @subscriber.update_areas(areas_ids)
      flash[:success] = "Les critères sont enregistrés ! Fermez cette fenêtre pour continuer."
    else
      flash[:danger] = "Sélectionnez des arrondissements..."
    end
    # // Send flow to subscriber 
    flow = "content20200716131717_882877"
    Manychat.new.send_flow_sequence(@subscriber, flow)
    redirect_to edit_subscriber_path
  end

  # ###############
  # OTHER 
  # ###############
  
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
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :has_messenger, :facebook_id, :max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor, :project_type, :additional_question, :specific_criteria, :broker_id, :status, :initial_areas, :terrace, :garden, :balcony, :new_construction, :last_floor, :min_price, :max_sqm_price)
  end
end
