FactoryBot.define do
  factory :lead do
    firstname { "Jean" }
    lastname { "Foutre" }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    phone { "0680088008" }
    max_price { 300000 }
    min_surface { 25 }
    min_rooms_number { 1 }
    has_messenger {true}
    project_type {"1er achat"}
    additional_question {"Comment rémunérez vous ? Le service devient-il payant ?"}
    specific_criteria {"Vue sur la Tour Eiffel"}
    broker {FactoryBot.create(:broker)}
    trello_id_card {"enrgrebuevbl"}
  end
end
