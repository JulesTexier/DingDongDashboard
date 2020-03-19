FactoryBot.define do
  factory :favorite do
    association :subscriber, factory: :subscriber
    association :property, factory: :property
  end
end
