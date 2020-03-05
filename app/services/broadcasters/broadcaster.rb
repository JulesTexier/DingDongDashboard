class Broadcaster

    attr_reader :manychat_client

    def initialize
        @manychat_client = Manychat.new
    end

    # Actual logic : Run every X minutes and process a batch of unprocessed new scrapped properties 
    def new_broadcast
        properties = self.get_unprocessed_properties
        properties.each do |prop|
            subscribers = prop.get_matching_subscribers
            subscribers.each do |sub|
                @manychat_client.send_single_property_card(sub, prop)
            end
            prop.has_been_processed = true 
            prop.save
        end
    end

    private

    def get_unprocessed_properties
        return Property.where(has_been_processed: false)
    end

    def update_processed_properties(properties)
        properties.each do |p|
            p.has_been_processed = true
            p.save
        end
    end

    def update_processed_property(property)
        property.has_been_processed = true
        property.save
    end


end