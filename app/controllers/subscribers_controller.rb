class SubscribersController < ApplicationController

  # Onboarding form "regular"
  def inscription_1
    @zone_select = ["Paris"]
  end

  def inscription_2
    selected_zones = params[:selected_zones]
    if selected_zones.nil? || Area.where(zone: selected_zones).empty?
      flash[:danger] = "Veuillez sélectionner une ou plusieurs zones de recherche 👇"
      redirect_to "/inscription-1"
    else
      @subscriber = Subscriber.new
      @zone = "Banlieue-Ouest"
      @areas = Area.where(zone: selected_zones)
    end
  end

  def inscription_3
    @draft_subscriber = params["subscriber"]
    @draft_subscriber["selected_areas"] = params["selected_areas"].join(",")
    @draft_subscriber["project_type"] = params["selected_project_types"].join(",")
    if @draft_subscriber.nil?
      flash[:danger] = "Une erreur est apparue, veuillez recommencer svp"
      redirect_to "/inscription-1"
    else
      @subscriber = Subscriber.new
    end
  end

  def inscription_4
    @subscriber = Subscriber.find(params["id"])
  end

  def create
    subscriber = Subscriber.where(email: subscriber_params["email"]).empty? ? Subscriber.new(subscriber_params) : Subscriber.where(email: subscriber_params["email"]).last
    if subscriber.handle_form_filled(subscriber_params)
      flash[:success] = "Nous avons bien reçu votre demande 🙂 Merci !"
      redirect_to "/inscription-finalisee?id=#{subscriber.id}"
    else
      flash[:danger] = "Une erreur s'est produite, veuillez recommencer svp"
      puts "ohoh, probleme"
      redirect_to "/inscription-1"
    end
  end

  # Onboarding form "subscription"
  def subscribe_1
    @zone_select = ["Paris"]
    # @zone_select = []
    # Area.all.each do |area|
    #   @zone_select << area.zone
    # end
    # @zone_select = @zone_select.uniq
  end

  def subscribe_2
    selected_zones = params[:selected_zones]
    if selected_zones.nil? || Area.where(zone: selected_zones).empty?
      flash[:danger] = "Veuillez sélectionner une ou plusieurs zones de recherche 👇"
      redirect_to "/inscription-1"
    else
      @subscriber = Subscriber.new
      @zone = "Banlieue-Ouest"
      @areas = Area.where(zone: selected_zones)
    end
  end

  def subscribe_3
    @draft_subscriber = params["subscriber"]
    @draft_subscriber["selected_areas"] = params["selected_areas"].join(",")
    @draft_subscriber["project_type"] = params["selected_project_types"].join(",")
    if @draft_subscriber.nil?
      flash[:danger] = "Une erreur est apparue, veuillez recommencer svp"
      redirect_to "/inscription-1"
    else
      @subscriber = Subscriber.new
    end
  end

  def subscribe_4
    @subscriber = Subscriber.find(params["id"])
    @shifts = ["Lundi matin", "Lundi après-midi", "Mardi matin", "Mardi après-midi", "Mercredi matin", "Mercredi après-midi", "Jeudi matin", "Jeudi après-midi", "Vendredi matin", "Vendredi après-midi"]
    @services = ["Chasseur immobilier", "Architecte d'intérieur", "Travaux", "Notaire", "Démenagement"]
    # @properties = @subscriber.get_x_last_props(5)
  end

  def subscribe_create
    subscriber = Subscriber.where(email: subscriber_params["email"]).empty? ? Subscriber.new(subscriber_params) : Subscriber.where(email: subscriber_params["email"]).last
    if subscriber.handle_form_filled(subscriber_params, "subscription")
      SubscriberStatus.create(subscriber: subscriber, status: Status.find_by(name:"subscription_bm"))
      # flash[:success] = "Nous avons bien reçu votre demande 🙂 Merci !"
      redirect_to "/subscribed?id=#{subscriber.id}"
    else
      flash[:danger] = "Une erreur s'est produite, veuillez recommencer svp"
      puts "ohoh, probleme"
      redirect_to "/subscribe-1"
    end
  end

  def subscribed_update
    subscriber = Subscriber.find(params["id"])
    if !params["free_financial_plan"].nil? && params["free_financial_plan"].include?("true")
      desc =  "Souhaite être recontacté #{params["shift"] if !params["shift"].nil?} - Il est interessé par les services suivants : #{params["services"]}"
      SubscriberStatus.create(subscriber: subscriber, status: Status.find_by(name:"accept_free_financial_audit"))
    else  
      desc = "Il n'a pas souhaité prendre l'audit gratuit ! - Il est interessé par les services suivants : #{params["services"]}"
      SubscriberStatus.create(subscriber: subscriber, status: Status.find_by(name:"do_not_accept_free_financial_audit"))
    end
    subscriber.update(additional_question: desc)
    Trello.new.add_comment_to_user_card(subscriber, desc) unless subscriber.trello_id_card.nil?
    SubscriberStatus.create(subscriber: subscriber, status: Status.find_by(name:"redirected_in_messenger"))
    redirect_to subscriber.get_chatbot_link
  end

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
    flow = "content20200616092144_217967"
    Manychat.new.send_flow_sequence(@subscriber, flow)
    redirect_to edit_subscriber_path
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :has_messenger, :facebook_id, :max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor, :project_type, :additional_question, :specific_criteria, :broker_id, :status, :initial_areas, :terrace, :garden, :balcony, :new_construction, :last_floor)
  end
end
