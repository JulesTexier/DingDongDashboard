class Favorite < ApplicationRecord

		after_create :notify_broker_if_new_fav_created
    
    belongs_to :subscriber, foreign_key: :subscriber_id, class_name: "Subscriber"
    belongs_to :property, foreign_key: :property_id, class_name: "Property"

    validates :subscriber, uniqueness: { scope: :property }

    private 

    def notify_broker_if_new_fav_created
      if !self.subscriber.broker.nil? && !self.subscriber.trello_id_card.nil?
			  self.subscriber.notify_broker_trello("Nouvelle annonce mise en favoris : \u000A #{self.property.get_title} \u000A #{self.property.link}") 
      end
    end

end
