FactoryBot.define do
  factory :property do
    price { 301000 }
    surface { 46 }
    rooms_number { 2 }
    area { "75018" }
    source { "Ding Dong" }
    images { ["https://image.com", "cache/forever", "https://icic-est-paris.com"] }
    link { "https://hellodingdong.com" }
  end
end
