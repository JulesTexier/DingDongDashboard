FactoryBot.define do
  factory :agglomeration do
    name { "Paris" }
    image_url { "https://ding-dong.s3.us-west-002.backblazeb2.com/agglomeration/paris.jpg" }
    is_active { true }
  end
end
