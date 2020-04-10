require "dotenv/load"
require "typhoeus"

class Api::V1::TypeformController < ApplicationController
  protect_from_forgery with: :null_session

  def initialize
    @trello = Trello.new
  end

    def generate_lead 
      # begin 
        
        document = JSON.parse(request.body.read)
        lead_hash = {}
        answers = document['form_response']['answers']
        lead_hash[:name] = answers[7]["text"]
        lead_hash[:phone] = answers[9]["phone_number"]
        lead_hash[:email] = answers[8]["email"]
        lead_hash[:has_messenger] = answers[6]["boolean"]
        lead_hash[:additional_question] = answers[5]["text"]
        lead_hash[:specific_criteria] = answers[4]["text"]
        lead_hash[:areas] = answers[3]["choices"]["labels"].join(",")
        lead_hash[:min_surface] = answers[2]["number"]
        lead_hash[:max_price] = answers[1]["number"]
        lead_hash[:project_type] = answers[0]["choice"]["label"]
        lead = Lead.new(lead_hash)

        b = Broker.get_current_broker
        lead.broker = b

        if lead.save

          # trello_auth = "key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_SECRET']}"
          list_id = b.trello_lead_list_id

          params = {}
          params[:name] = lead_hash[:name]
          params[:desc] = lead.trello_description
          params[:pos] = 'top'
          params[:due] = Time.now + 15.minutes
          params[:idMembers] = b.trello_id

          # 1• Create card on tello Board 
          new_card_response = @trello.create_new_card(list_id, params)


          # 2• Add checklist 'Action' to created card
          card_id = JSON.parse(new_card_response.body)["id"]
          lead.update(trello_id_card: card_id)

          new_checklist_response = @trello.add_checklist_to_card(card_id)

          # 3• Add first action on the checklist
          checklist_id = JSON.parse(new_checklist_response.body)["id"]
          check_items_params = {}
          check_items_params[:name] = "Rentrer en contact avec #{lead.name}"
          
          @trello.add_checkitem_to_checklist(checklist_id, check_items_params)

          if response.code == 200
            render json: {status: 'SUCCESS', message: 'Lead added to Trello !', data: lead}, status: 200
          else
            render json: {status: 'ERROR', message: 'An errro occured'}, status: 500
          end
        end
      # rescue
      #   render json: {status: 'ERROR', message: 'An errro occured'}, status: 500
      # end


    end


end
