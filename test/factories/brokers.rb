FactoryBot.define do
  factory :broker do
    firstname { "Firstname" }
    lastname { "Lastname" }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    phone { "0680088008" }
    trello_id { "trello_id" }
    trello_lead_list_id { "trello_lead_list_id" }
    trello_board_id { "trello_board_id" }
    trello_username { "username" }

    factory :subscriber_aurelien do 
      trello_username {'aurelienguichard1'}
    end

    factory :subscriber_melanie do 
      trello_username {'melanieramon2'}
    end

    factory :subscriber_veronique do 
      trello_username {'veroniquebenazet'}
    end

    factory :subscriber_hugo do 
      trello_username {'cohen172'}
    end

    factory :subscriber_amelie do 
      trello_username {'kleinamelie'}
    end

    factory :subscriber_greg do 
      trello_username {'gregrouxeloldra'}
    end


  end
end
