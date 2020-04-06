require "dotenv/load"
require "typhoeus"

class Api::V1::TypeformController < ApplicationController
  protect_from_forgery with: :null_session


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

          trello_auth = "key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_SECRET']}"

          params = {}
          params[:name] = lead_hash[:name]
          params[:desc] = lead.trello_description
          params[:pos] = 'top'
          params[:due] = Time.now + 15.minutes

          params[:idMembers] = b.trello_id

          # 1• Create card on tello Board 
          request = Typhoeus::Request.new(
            "https://api.trello.com/1/cards?idList=#{b.trello_lead_list_id}&" + trello_auth,
            method: :post,
            params: params
          )
          response = request.run


          # 2• Add checklist 'Action' to created card
          card_id = JSON.parse(response.body)["id"]


          checklist_params = {}
          checklist_params[:name] = "ACTIONS"
          request = Typhoeus::Request.new(
            "https://api.trello.com/1/cards/#{card_id}/checklists?" + trello_auth,
            method: :post,
            params: checklist_params
          )
          response = request.run

          # 3• Add first action on the checklist
          checklist_id = JSON.parse(response.body)["id"]
          check_items_params = {}
          check_items_params[:name] = "Rentrer en contact avec #{lead.name}"
          request = Typhoeus::Request.new(
            "https://api.trello.com/1/checklists/#{checklist_id}/checkItems?" + trello_auth,
            method: :post,
            params: check_items_params
          )
          response = request.run

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
