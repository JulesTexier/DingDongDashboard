FactoryBot.define do
  factory :status do
    name { "onboarded" }
    description { "When a user is fully onboarded" }
    status_type { "acquisition" }
  end
end
