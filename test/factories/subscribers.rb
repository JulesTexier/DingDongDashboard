FactoryBot.define do
  factory :subscriber do
    firstname { "Jean" }
    lastname { "Foutre" }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    phone { "0680088008" }
    facebook_id { "fb000001" }
    broker { FactoryBot.create(:broker) }
    notary { FactoryBot.create(:notary) }
    contractor { FactoryBot.create(:contractor) }

    factory :subscriber_fred do
      facebook_id { "3558864844155233" }
    end

    factory :subscriber_fred_prod do
      facebook_id { "2827641220632020" }
    end

    factory :subscriber_dummy_fb_id do
      facebook_id { rand(10..99).to_s + rand(10..99).to_s + rand(10..99).to_s + rand(10..99).to_s }
    end

    factory :subscriber_no_broker do
      broker { nil }
    end
  end
end
