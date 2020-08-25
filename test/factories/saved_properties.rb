FactoryBot.define do
  factory :saved_property do
    research_id { FactoryBot.create(:subscriber_research).id }
    property_id { FactoryBot.create(:property).id }
  end
end
