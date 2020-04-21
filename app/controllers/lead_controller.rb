class LeadController < ApplicationController
  def new
    @lead = Lead.new
    @areas = Area.all
    @brokers = Broker.all
    @broker_select = []
    @broker_select << ["Chosir...", ""]
    Broker.all.each do |broker|
      @broker_select << "#{broker.firstname} #{broker.lastname}" 
    end
  end

  def create
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

  private

  def lead_params
    params.require(:lead).permit(:firstname, :lastname, :email, :phone, :has_messenger, :max_price, :min_surface, :min_rooms_number, :project_type, :additional_question, :specific_criteria, :areas, :status, :source, :broker_id, :has_messenger)
  end 

end
