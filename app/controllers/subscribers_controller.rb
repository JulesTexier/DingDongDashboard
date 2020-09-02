class SubscribersController < ApplicationController  

  # ###############
  #      CRUD     #
  # ###############

  def new
    @subscriber = Subscriber.new
  end

  def create
    subscriber = Subscriber.new(subscriber_params)
    if subscriber.save
    else
      flash[:error] = "Un problème est apparu, veuillez réessayer."
      render 'new'
    end
  end

  def edit
    @subscriber = Subscriber.find(params[:id])
    @research = @subscriber.research
    @research.update(zone: params[:selected_zones]) unless params[:selected_zones].nil?
    subscriber_areas_id = @research.areas.pluck(:id)
    if params[:selected_zones].nil? && subscriber_areas_id.empty?
      flash[:danger] = "Veuillez sélectionner une zone de recherche."
      redirect_to "/subscribers/" + params[:id] + "/agglomeration"
    elsif subscriber_areas_id.any?
      @master_areas = Area.get_selected_agglo_area(@research.zone, subscriber_areas_id)
      @master_areas += Area.global_zones(@research.zone)
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
    if @research.update(subscriber_params) && !areas_ids.empty?
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

  def professionals
    @subscriber = Subscriber.find(params[:subscriber_id])
    @notary = @subscriber.notary
    @broker = @subscriber.broker
    @contractor = @subscriber.contractor
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

  def confirm_email
    subscriber = Subscriber.find_by_confirm_token(params[:token])
    if subscriber
      subscriber.validate_email
      subscriber.save(validate: false)
      SubscriberMailer.welcome_email(subscriber).deliver_now
      redirect_to subscriber_email_confirmed_path(subscriber)
    else
      flash[:error] = "Désolé, l'utilisateur n'existe pas"
      redirect_to url_not_found_path
    end
  end

  def email_validation
    @subscriber = Subscriber.find(params[:subscriber_id])
  end

  def email_confirmed
    subscriber = Subscriber.find(params[:subscriber_id])
    redirect_to root_path if subscriber.messenger_flux || !subscriber 
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :has_messenger, :facebook_id, :max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor, :project_type, :additional_question, :specific_criteria, :broker_id, :status, :initial_areas, :terrace, :garden, :balcony, :new_construction, :last_floor, :min_price, :max_sqm_price)
  end
end

