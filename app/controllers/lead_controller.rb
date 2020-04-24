class LeadController < ApplicationController
  def onboarding
    @zone_select = []
    Area.all.each do |area|
      @zone_select << area.zone 
    end
    @zone_select = @zone_select.uniq
  end

  def new_broker
    @lead = Lead.new
    @areas = Area.all
    @brokers = Broker.all
    @broker_select = []
    @broker_select << ["Chosir...", ""]
    Broker.all.each do |broker|
      @broker_select << "#{broker.firstname} #{broker.lastname}" 
    end
  end

  def create_broker
    lead = Lead.new(lead_params)
    lead.areas = params[:selected_areas].join(",") if !params[:selected_areas].nil?
    lead.has_messenger = true
    lead.status = "broker_form_filled"
    lead.source += " (lead généré par le courtier)"
    if lead.save 
      flash[:success] = "Le contact a bien été créé ! Tu peux le retrouver dans ton Trello"
      redirect_to :action => "new"
    else 
      flash[:danger] = "Une erreur s'est produite ..."
      puts "ohoh, probleme"
    end
  end

  def new
    selected_zones = params[:selected_zones]
    if selected_zones.nil? || Area.where(zone: selected_zones).empty?
      flash[:danger] = "Zone de recherche non reconnue"
      redirect_to "/lead/onboarding"
    else
      @lead = Lead.new()
      @zone = "Banlieue-Ouest"
      @areas = Area.where(zone: selected_zones)
    end
  end

  def create
  end

  private

  def lead_params
    params.require(:lead).permit(:firstname, :lastname, :email, :phone, :has_messenger, :max_price, :min_surface, :min_rooms_number, :project_type, :additional_question, :specific_criteria, :areas, :status, :source, :broker_id, :has_messenger)
  end 

end
