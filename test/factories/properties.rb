FactoryBot.define do
  factory :property do
    price { 600000 }
    surface { 60 }
    rooms_number { 1 }
    area { "75001" }
    link { "https://hellodingdong.com" }
    source { "DingDong" }
    floor { 1 }
    has_elevator { true }
  end
end
