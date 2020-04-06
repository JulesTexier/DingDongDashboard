class Api::V1::TypeformController < ApplicationController

    def generate_lead 
      byebug
      document = JSON.parse(request.body.read)
      lead = {}
      lead[:answers] = document['form_response']['answers']
      lead[:name] = answers[7]["text"]
      lead[:phone] = anwers[9]["phone_number"]
      lead[:email] = anwers[8]["email"]
      lead[:has_messenger] = anwers[6]["boolean"]
      lead[:question] = anwers[5]["text"]
      lead[:more_criteria] = anwers[4]["text"]
      lead[:areas] = ansewers[3]["choices"]["labels"].join(",")
      lead[:min_surface] = answers[2]["number"]
      lead[:max_price] = answers[1]["number"]
      lead[:project_type] = answers[0]["choice"]["label"]

      lead = Lead.new(lead)
      if lead.save
        puts "A new lead has been genrated"
      else
        puts "Oops, error while genrating a new lead"
      end


    end

end
