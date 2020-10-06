FactoryBot.define do
  factory :research do
    factory :subscriber_research do
      max_price { 300000 }
      min_price { 100000 }
      last_floor { false }
      min_surface { 25 }
      min_rooms_number { 1 }
      subscriber { FactoryBot.create(:subscriber) }
    end
  end
end
