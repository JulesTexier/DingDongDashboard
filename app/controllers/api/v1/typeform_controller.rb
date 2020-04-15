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
    puts "REQUEST : "
    puts request.body.read
    puts "*"*10

    document = JSON.parse(request.body.read)
    lead_hash = {}
    questions = document['form_response']['answers']
    questions.each do |q|
      case q["field"]["id"]
      when "aGkhhYOKuUCt"
        lead_hash[:max_price] = q["number"]
      when "p0arvZv5ItXj"
        lead_hash[:min_surface] = q["number"]
      when "AyRA34Ph5L34"
        lead_hash[:areas] = q["choices"]["labels"].join(",")
      when "TxGNsw4uYCkJ"
        lead_hash[:min_rooms_number] = q["number"]
      when "uK91am1GTnip"
        lead_hash[:specific_criteria] = q["text"]
      when "AhoulpInovin"
        lead_hash[:project_type] = q["choice"]["label"]
      when "G5iKFd5ed0to"
        lead_hash[:additional_question] = q["text"]
      when "UwhWRdoW9ukL"
        lead_hash[:has_messenger] = q["boolean"]
      when "tPDaIN7pPEwe"
        lead_hash[:firstname] = q["text"]
      when "BfOAVvTM0DgI"
        lead_hash[:lastname] = q["text"]
      when "yfT6AYau3EnW"
        lead_hash[:email] = q["email"]
      when "fjNwZTr8I0DS"
        lead_hash[:phone] = q["phone_number"]
      else 
      end
    end

    lead = Lead.new(lead_hash)
    lead.broker = Broker.get_current_broker
    lead.save ?  lead : false
  end


end
