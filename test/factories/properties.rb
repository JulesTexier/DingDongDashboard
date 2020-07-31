FactoryBot.define do
  factory :property do
    price { 301000 }
    surface { 46 }
    rooms_number { 2 }
    area { Area.first }
    source { "Ding Dong" }
    description { "À 50 mètres du M°Jules Joffrin et de la mairie, dans immeuble pierre de taille        , chaleureux 2 pièces de 37,20 m² comprenant entrée, séjour, cuisine séparée, chambre, WC séparés, salle de bains, cave. Parquets, moulures, cheminée. 1er étage vue sur l’église. À rafraichir. EXCLUSIVITÉ ACOPA." }
    images { ["https://images.pexels.com/photos/117602/pexels-photo-117602.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=75&w=126", "cache/forever", "https://icic-est-paris.com"] }
    link { "https://hellodingdong.com" }
    flat_type { "Maison" }
  end
end
