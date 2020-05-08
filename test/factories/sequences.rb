FactoryBot.define do
  factory :sequence do
    name { "Super Sequence Regular" }
    sender_email { "lagencedu17@gmail.com" }
    sender_name { "Christine" }
    source { "SeLoger-Logic" }
    is_active { true }
    trigger_ads { [] }
    description { "Super description pour cette sequence" }
    sequence_type { "Mail" }
    marketing_type { "regular" }
  end
end
