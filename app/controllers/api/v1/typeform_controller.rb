require "dotenv/load"
require "typhoeus"

class Api::V1::TypeformController < ApplicationController
  protect_from_forgery with: :null_session


    def generate_lead 
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
      if lead.save
        puts "A new lead has been generated"

        params = {}
        params[:name] = lead_hash[:name]
        params[:desc] = lead.trello_summary
        params[:pos] = 'top'

        request = Typhoeus::Request.new(
          "https://api.trello.com/1/cards?idList=5e732e43da3a0d8d512c88d0&key=bd3b7da95b0121bd8bdea25ff2ab5d50&token=11e09ded7eeceabe509408840639cd97864ca350310fa85ec3cd4ab5389bd97d",
          method: :post,
          params: params
        )
        response = request.run
        if response.code == 200
          render json: {status: 'SUCCESS', message: 'Lead added to Trello !', data: lead}, status: 200
        end


      else
        puts "Oops, error while genrating a new lead"
      end


    end

end
