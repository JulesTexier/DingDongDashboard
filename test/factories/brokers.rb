FactoryBot.define do
  factory :broker do
    firstname { (0...50).map { ('a'..'z').to_a[rand(26)] }.join }
    lastname { (0...50).map { ('a'..'z').to_a[rand(26)] }.join }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    phone { "0680088008" }
    trello_id { "trello_id" }
    trello_lead_list_id { "trello_lead_list_id" }
    trello_board_id { "trello_board_id" }
    trello_username { "username" }
    password { 'dingdong' }

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

    factory :broker_greg do 
      trello_username {'gregrouxeloldra'}
    end

    factory :broker_etienne do 
      trello_username {'etienne_dingdong'}
    end


  end
end
