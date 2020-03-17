FactoryBot.define do
  factory :property do
    price { 600000 }
    surface { 60 }
    rooms_number { 1 }
    area { "75010" }
    source { "Ding Dong" }
    link { "https://hellodingdong.com" }
  end
end
