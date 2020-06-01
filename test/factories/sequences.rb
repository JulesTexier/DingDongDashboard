FactoryBot.define do
  factory :sequence do
    name { "Super Sequence Regular" }
    sender_email { "lagencedu17@gmail.com" }
    sender_name { "Christine" }
    source { "SeLoger-Logic" }
    is_active { true }
    trigger_ads { [] }
    description { "Super description pour cette sequence" }
    marketing_type { "regular" }
    marketing_link { "https://hellodingdong.com/home.html" }

    factory :sequence_subscriber_bm do
      name { "HACK - test abonnement payant" }
      marketing_type { "hack" }
    end
  end
end
