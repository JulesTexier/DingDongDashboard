FactoryBot.define do
  factory :property do
    price { 301000 }
    surface { 46 }
    rooms_number { 2 }
    area { "75018" }
    source { "Ding Dong" }
    link { "https://hellodingdong.com" }
  end
end
