class Favorite < ApplicationRecord
    
    belongs_to :subscriber, foreign_key: :subscriber_id, class_name: "Subscriber"
    belongs_to :property, foreign_key: :property_id, class_name: "Property"

    validates :subscriber, uniqueness: { scope: :property }

end
