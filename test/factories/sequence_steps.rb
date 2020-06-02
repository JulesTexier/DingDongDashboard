FactoryBot.define do
  factory :sequence_step do
    step { 1 }
    name { "Premier Email" }
    description { "Premier email qu'on envoie" }
    step_type { "shoot_mail" }
    time_frame { 0 }
  end
end
