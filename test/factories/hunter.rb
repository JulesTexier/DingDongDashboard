FactoryBot.define do
  factory :hunter do
    firstname { "Chasseur" }
    lastname { "Immo" }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    password { "password" }
    phone { "0680088008" }
    company { "Ding Dong" }
  end
end
