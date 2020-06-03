FactoryBot.define do 
  factory :broker_shift do 
    factory :broker_shift_regular do 
      shift_type {'regular'}
    end
    factory :broker_shift_subscription do 
      shift_type {'subscription'}
    end
    factory :broker_shift_morning do 
      starting_hour {9}
      ending_hour {12}
    end
    factory :broker_shift_afternoon do 
      starting_hour {13}
      ending_hour {20}
    end
  end
end