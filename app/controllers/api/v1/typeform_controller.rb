class Api::V1::TypeformController < ApplicationController
  protect_from_forgery with: :null_session


    def generate_lead 
      document = JSON.parse(request.body.read)
      lead = {}
      answers = document['form_response']['answers']
      lead[:name] = answers[7]["text"]
      lead[:phone] = answers[9]["phone_number"]
      lead[:email] = answers[8]["email"]
      lead[:has_messenger] = answers[6]["boolean"]
      lead[:additional_question] = answers[5]["text"]
      lead[:specific_criteria] = answers[4]["text"]
      lead[:areas] = answers[3]["choices"]["labels"].join(",")
      lead[:min_surface] = answers[2]["number"]
      lead[:max_price] = answers[1]["number"]
      lead[:project_type] = answers[0]["choice"]["label"]
      lead = Lead.new(lead)
      if lead.save
        puts "A new lead has been generated"
      else
        puts "Oops, error while genrating a new lead"
      end


    end

end
