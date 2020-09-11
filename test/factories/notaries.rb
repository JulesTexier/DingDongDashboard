FactoryBot.define do
  factory :notary do
    firstname { "Jean" }
    lastname { "Notaire" }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    phone { "0680088008" }
  end
end
