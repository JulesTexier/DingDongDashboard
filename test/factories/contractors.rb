FactoryBot.define do
  factory :contractor do
    firstname { "Jean" }
    lastname { "Entrepreneur" }
    email { "#{firstname}.#{lastname}@email.com".downcase }
    phone { "0680088008" }
  end
end
