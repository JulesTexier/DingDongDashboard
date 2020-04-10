require "dotenv/load"
require "typhoeus"

class Api::V1::TypeformController < ApplicationController
  protect_from_forgery with: :null_session

  def initialize
    @trello = Trello.new
  end

  def generate_lead 
    lead = generate_lead_from_typeform_data(request)
  
    if lead
      response = @trello.add_new_lead_on_trello(lead)
      if response
        render json: {status: 'SUCCESS', message: 'Lead added to Trello !', data: lead}, status: 200
      else
        render json: {status: 'ERROR', message: 'An errro occured'}, status: 500
      end
    end
  end

  private 

  def generate_lead_from_typeform_data(request)
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
    lead.broker = Broker.get_current_broker
    lead.save ?  lead : false
  end


end
