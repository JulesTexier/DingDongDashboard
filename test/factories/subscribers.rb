FactoryBot.define do
  factory :subscriber do
    firstname { "Jean" } 
    lastname { "Foutre" }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    phone { "0680088008" }
    max_price { 300000 }
    min_surface { 25 }
    min_rooms_number { 1 }
    facebook_id { "fb000001" }
    project_type { "1er achat" }
    has_messenger { true }
    status {"form filled" }
    broker { FactoryBot.create(:broker) }
    initial_areas { FactoryBot.create(:area).id }

    factory :subscriber_fred do
      facebook_id { "3558864844155233" }
    end

    factory :subscriber_fred_prod do
      facebook_id { "2827641220632020" }
    end

    factory :subscriber_dummy_fb_id do
      facebook_id { rand(10..99).to_s + rand(10..99).to_s + rand(10..99).to_s + rand(10..99).to_s }
    end
  end
end
