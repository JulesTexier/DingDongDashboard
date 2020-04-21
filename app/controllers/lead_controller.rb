class LeadController < ApplicationController
  def create
    @lead = Lead.new
    @areas = Area.all
    @broker_select = []
    @broker_select << ["Chosir...", ""]
    Broker.all.each do |broker|
      @broker_select << "#{broker.firstname} #{broker.lastname}" 
    end
  end

  def handle_lead_broker
    permitted = params.require(:lead).permit(:firstname, :lastname)
    lead = Lead.new(permitted)
    byebug
  end
end
