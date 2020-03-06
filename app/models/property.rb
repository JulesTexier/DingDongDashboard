
DEFAULT_IMG_URL = "https://hellodingdong.com/placeholder.jpg"

class Property < ApplicationRecord

    # after_save :broadcast

    validates :price, presence: true
    validates :surface, presence: true
    validates :rooms_number, presence: true
    validates :area, presence: true
    validates :source, presence: true
    validates :link, presence: true, format: { with: /https?:\/\/[\S]+/i, message: "link format is not valid" }

    has_many :favorites
    has_many :fans, through: :favorites, source: :subscriber

    has_many :property_districts
    has_many :districts, through: :property_districts


    has_many :property_images

    def images
      return self.property_images
    end

    def get_images
        default_img = {}
        default_img['url'] = DEFAULT_IMG_URL

        if self.property_images.count == 0 
            return [default_img] 
        else 
            images = []
            self.property_images.each do |pi|
                images.push(pi.as_json)
            end
            return images
        end
    end

    def get_cover
        default_img = {}
        default_img['url'] = DEFAULT_IMG_URL

        if self.images.empty? 
            return default_img['url']
        else
            return self.images.first.url
        end
    end

    def get_title
        return "🏠 " + self.price.to_s + "€ - " + self.surface.to_s + "m2 - " + self.area
    end

    def get_attribues_description
        description = ''
        self.price > 0 ? description = description + "\u000A💰 " + self.price.to_s + " €" : nil
        self.surface > 0 ? description = description + "\u000A📐 " + self.surface.to_s + " m2" : nil
        self.surface > 0 && self.price > 0 ? description = description + "\u000A💡 " + (self.price / self.surface).to_i + " €/m2" : nil
        self.area != nil ? description = description + "\u000A📌 " + self.area : nil
        description = description + "\u000A⏱️ Postée le " + self.created_at.strftime("%-d/%-m à %-dh%-d").to_s : nil
        description += self.get_short_description        
        return description
    end

    def get_short_description
        description = ''
        self.street != "N/C" && self.street != nil ? description = description + "📍 " + self.street : nil
        self.districts.count > 0 ? description = description + "\u000A🏙️ " + self.districts.map(&:name).join(", ") : nil
        self.rooms_number > 1 ? description += "\u000A🛋️  " + self.rooms_number.to_s + " pièces" : description += description = "\u000A🛏️  " + self.rooms_number.to_s + " pièce"
        self.floor != nil ? description = description + "\u000A↕ " + "Etage : " + self.floor.to_s : nil
        self.has_elevator ? description = description + "\u000A🚠 Avec ascenseur" : nil

        return description
    end

    def get_long_description
        description = ''
        self.description != "N/C" && !self.description.nil? ? description = "Description 💬 :\u000A" + self.description[0..600] + " ..." : nil
        return description
    end

    def get_matching_subscribers

        # 1. Surface, price and rooms_number criterias, floor
        floor.nil? ? virtual_floor = 1000 : virtual_floor = floor
        subs_query =  Subscriber.where(
            is_active: true,
            max_price: price..Float::INFINITY,
            min_surface: Float::INFINITY..surface,
            min_rooms_number: Float::INFINITY..rooms_number,
            min_floor: Float::INFINITY..virtual_floor
        )

        # 2. Area criteria
        subs = []
        subs_query.each do |sub|
            sub.areas.each do |sub_area|
                sub_area.name === area  ? subs.push(sub) : nil
            end
        end

        # 3. elevator criteria 
        final_subs = []
        if has_elevator === false && floor != nil
            subs.each do |sub| 
                sub.min_elevator_floor > floor ?  final_subs.push(sub) : nil 
            end
        else
            final_subs = subs
        end


        return final_subs

    end

    # Broadcast property to all matching subscribers 
    def broadcast
        m = Manychat.new
        subs =  self.get_matching_subscribers
        subs.each do |sub|
            m.send_single_property_card(sub, self)
        end
    end


end