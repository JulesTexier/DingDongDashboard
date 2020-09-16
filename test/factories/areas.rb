FactoryBot.define do
  factory :area do
    name { "Paris 1er" }
    description { "Magnifique arrondissement." }
    department { FactoryBot.create(:department) }
  end
end
