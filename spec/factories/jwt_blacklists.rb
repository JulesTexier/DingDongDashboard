FactoryBot.define do
  factory :jwt_blacklist do
    jti { "MyString" }
    exp { "2020-11-24 10:59:23" }
  end
end
