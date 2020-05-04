class SubscribersController < ApplicationController

  # Onboarding form 
  def inscription_1
    @zone_select = []
    Area.all.each do |area|
      @zone_select << area.zone 
    end
    @zone_select = @zone_select.uniq
  end

  def inscription_2
    selected_zones = params[:selected_zones]
    if selected_zones.nil? || Area.where(zone: selected_zones).empty?
      flash[:danger] = "Zone de recherche non reconnue"
      redirect_to "/subscribers/inscription-1"
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
      flash[:danger] = "Un erreur est apparue, veuillez recommencer svp"
      redirect_to "/susbcribers/inscription-1"
    else
      @subscriber = Subscriber.new
    end
  end

  def inscription_4
    @subscriber = Subscriber.find(params["id"])
  end

  def create
    subscriber = Subscriber.new(subscriber_params)
    subscriber.status = "form_filled"
    if subscriber.save 
      subscriber.initial_areas.split(",").each do |area_id|
        SelectedArea.create(subscriber: subscriber, area_id: area_id)
      end
      flash[:success] = "Nous avons bien reçu ta demande 🙂 Merci !"
      redirect_to "/subscribers/inscription-finalisee?id=#{subscriber.id}"
    else 
      flash[:danger] = "Une erreur s'est produite, veuillez recommencer svp"
      puts "ohoh, probleme"
      redirect_to "/subscribers/inscription-1"
    end
  end
  
  # Edit form 
  def edit
    @subscriber = Subscriber.find(params[:id])
    zone_areas = []
    @subscriber.areas.each do |area|
      zone_areas.push(area.zone)
    end
    zone_areas.uniq
    @areas = Area.where(zone:zone_areas)
  end

  def update
    @subscriber = Subscriber.find(params[:id])
    SelectedArea.where(subscriber: @subscriber).destroy_all
    if @subscriber.update(subscriber_params) && !params[:selected_areas].nil?
      params[:selected_areas].each do |area_id|
        SelectedArea.create(subscriber:@subscriber, area_id:area_id)
      end
      flash[:success] = "Les critères sont enregistrés ! Ferme cette fenêtre pour continuer."
    else 
      flash[:danger] = "Sélectionne des arrondissements..."
      # @subscriber.errors.full_messages.each do |message|
      #   flash[:danger] << message
      # end
      # flash[:danger] = flash[:danger].join(" & ")
    end
    redirect_to edit_subscriber_path
  end


  private

  def subscriber_params
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :has_messenger, :facebook_id, :max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor, :project_type, :additional_question, :specific_criteria, :broker_id, :status, :initial_areas)
  end 

end
