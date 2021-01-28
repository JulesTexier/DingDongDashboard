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
        simulation_attributes = []
        simulation_attributes.push({name: "loan_amount", value: params[:loan_amount], label: "Montant du prêt", unit: "€"})
        simulation_attributes.push({name: "loan_job_situation", value: params[:loan_family_situation], label: "Emprunte", unit: ""})
        simulation_attributes.push({name: "loan_job_situation", value: params[:loan_job_situation], label: "Situation professionnelle", unit: ""})
        simulation_attributes.push({name: "loan_revenue", value: params[:loan_revenue], label: "Revenus annuels", unit: "€"})
        simulation_attributes.push({name: "loan_charges", value: params[:loan_charges], label: "Charges mensuelles", unit: ""})
        simulation_attributes.push({name: "loan_charges_amount", value: params[:loan_charges_amount], label: "Montant mensuel autres prêts", unit: "€"})

        BrokerManager::LoanManager::HandleLoanSimulation.call(current_subscriber.id, simulation_attributes)

        render json: {status: 'SUCCESS', message: "Email sent with success", data: {subscriber_note: current_subscriber.subscriber_notes.last} }, status: 200
    end

    def get_property_details 
        begin
            property = Property.find(params[:ads_id])
            ad = {}
            ad[:property] = property.as_json
            ad[:area] = property.area
            render json: {status: 'SUCCESS', message: "Property updated", data: ad.as_json}, status: 200
          rescue ActiveRecord::RecordNotFound
            render json: {status: 'ERROR', message: 'Property not found'}, status: 422   
          end
    end

    def create_subscriber_note
        begin 
            sn = SubscriberNote.create!(subscriber: current_subscriber, content: params[:content])
            render json: {status: 'SUCCESS', message: "SubscriberNote created", data: sn.as_json}, status: 200
        rescue ActiveRecord::RecordInvalid
            render json: {status: 'ERROR', message: 'SubscriberNote not created'}, status: 422
        end
    end

    private

    def subscriber_params
        params.require(:subscribers_dashboard).require(:subscriber).permit(:firstname, :lastname, :email, :phone, :facebook_id, :broker_status, :broker_comment, :hot_lead, :broker_meeting, :is_active)
    end  
    
    def research_params
        params.require(:subscribers_dashboard).require(:research).permit(:max_price, :min_price, :min_floor, :min_elevator_floor, :has_elevator, :min_surface, :min_rooms_number, :max_sqm_price, :is_active, :balcony, :terrace, :garden, :new_construction, :last_floor, :home_type, :apartment_type)
    end

    

end
