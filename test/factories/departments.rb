FactoryBot.define do
  factory :department do
    name { "Paris (75)"}
    agglomeration { FactoryBot.create(:agglomeration) }
  end
end
