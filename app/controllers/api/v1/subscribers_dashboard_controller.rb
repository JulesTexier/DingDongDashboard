require 'dotenv/load'

class Api::V1::SubscribersDashboardController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

    before_action :authenticate_and_set_subscriber

    def current 
        returned_subscriber = current_subscriber.as_json
        returned_subscriber[:messenger_link] = current_subscriber.messenger_link
        returned_subscriber[:research] = current_subscriber.research
        returned_subscriber[:areas] = current_subscriber.research.areas
        render json: {user: returned_subscriber}, status: 200
    end

    def research_properties
        begin 
            properties = ResearchManager::ResearchProperties.call(current_subscriber.research.id, 120)
            data = properties.map{|p| {property: p, area: p.area}}
            render json: {status: 'SUCCESS', message: "Matching properties", data: data}, status: 200
        rescue 
            render json: {status: 'ERROR', message: 'Subscriber\'s research not found'}, status: 422     
        end
    end

    def update
        begin 
            current_subscriber.update(subscriber_params) unless params[:subscriber].nil?
            current_subscriber.research.update(research_params) unless params[:research].nil?
            if !params[:areas].nil? && !params[:areas].empty?
                current_subscriber.research.research_areas.each{ |ra| ra.destroy}
                current_subscriber.research.areas << Area.where(id: params[:areas])
            end
            render json: {status: 'SUCCESS', message: "Subscriber has been updated", data: {subscriber: current_subscriber, research: current_subscriber.research, areas: current_subscriber.research.areas } }, status: 200
        rescue 
            render json: {status: 'ERROR', message: 'Subscriber could no be updated'}, status: 422     
        end
    end

    def loan_simulation
        simulation_attributes = {}
        simulation_attributes[:montant] = params[:loan_amount]
        simulation_attributes[:situation_marritale] = params[:loan_family_situation]
        simulation_attributes[:situation_professionelle] = params[:loan_job_situation]
        simulation_attributes[:revenus_mensuels] = params[:loas_revenue]
        simulation_attributes[:charges_mensuelles] = params[:loan_charges]
        simulation_attributes[:montant_prets] = params[:loan_charges_amount]
        
        BrokerManager::LoanManager::CreateSubscriberNote.call(current_subscriber.id, simulation_attributes)
        BrokerMailer.new_hot_lead(current_subscriber.id, simulation_attributes).deliver_now

        render json: {status: 'SUCCESS', message: "Email sent with success", data: {subscriber_note: current_subscriber.subscriber_notes.last} }, status: 200
    end

    private

    def subscriber_params
        params.require(:subscribers_dashboard).require(:subscriber).permit(:firstname, :lastname, :email, :phone, :facebook_id, :broker_status, :broker_comment, :hot_lead, :broker_meeting, :is_active)
    end  
    
    def research_params
        params.require(:subscribers_dashboard).require(:research).permit(:max_price, :min_price, :min_floor, :min_elevator_floor, :has_elevator, :min_surface, :min_rooms_number, :max_sqm_price, :is_active, :balcony, :terrace, :garden, :new_construction, :last_floor, :home_type, :apartment_type)
    end

    

end
