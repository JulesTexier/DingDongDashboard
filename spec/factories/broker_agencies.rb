FactoryBot.define do
  factory :broker_agency do
    name { "Agence de courtage" }
    max_period_leads { 100 }
    current_period_leads_left { 80 }
    default_pricing_lead { 6 }
    agglomeration_id { FactoryBot.create(:agglomeration).id }
    status { "premium" }   
    current_period_provided_leads { 20 }
  end
end