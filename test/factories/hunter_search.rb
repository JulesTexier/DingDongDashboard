FactoryBot.define do
  factory :hunter_search do
    min_price { 300000 }
    max_price { 1000000 }
    min_surface { 25 }
    min_rooms_number { 1 }
    min_floor { 1 }
    min_elevator_floor { 3 }
    hunter { FactoryBot.create(:hunter) }
  end
end
