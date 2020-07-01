DEFAULT_IMG_URL = "https://hellodingdong.com/placeholder.jpg"

class Property < ApplicationRecord
  validates :price, presence: true
  validates :surface, presence: true
  validates :rooms_number, presence: true
  validates :area, presence: true
  validates :source, presence: true
  validates :link, presence: true, format: { with: /https?:\/\/[\S]+/i, message: "link format is not valid" }

  validate :image_array_validator
  validate :image_link_validator

  has_many :favorites
  has_many :fans, through: :favorites, source: :subscriber

  has_many :selections
  has_many :hunter_selections, through: :selections, source: :hunter_search

  has_many :property_districts
  has_many :districts, through: :property_districts

  serialize :subway_infos, Array

  belongs_to :area

  def get_cover
    self.images[0]
  end

  def manychat_show_description
    description = "🛋️ " + self.rooms_number.to_s + "p" if self.rooms_number >= 1
    description += "   ↕ Et. " + self.floor.to_s unless self.floor.nil?
    description += "   🚠 Asc" if self.has_elevator
    description += "  💰#{(self.price / self.surface).round(0)}"
    description += " €/m2" if description.length < 25
    description += "\u000AⓂ️ #{self.get_subways_full}" if !self.subway_infos.empty?
    description += "\u000A⏱️ " + self.created_at.in_time_zone("Europe/Paris").strftime("%d/%m").to_s + " à " + self.created_at.in_time_zone("Europe/Paris").strftime("%H:%M").to_s
  end

  def manychat_show_description_with_title
    description = ""
    description += self.get_title + "\u000A"
    description += self.manychat_show_description
  end

  def get_title
    return "🏠 " + self.get_pretty_price + "€ - " + self.surface.to_s + "m2 - " + get_pretty_area
  end

  def get_pretty_area
    if self.area.name[0..1] == "75"
      if self.area.name[3..3] == "0"
        self.area.name[4..4] == "1" ? pretty_area = "1er" : pretty_area = "#{self.area.name[4..4]}ème"
      else
        pretty_area = "#{self.area.name[3..4]}ème"
      end
    else
      pretty_area = self.area.name
    end
    return pretty_area
  end

  def get_subways_full
    stops = []
    lines_arr = []
    self.subway_infos.each do |subway|
      stops.push(subway["name"])
      lines_arr.push(subway["line"])
    end
    lines_arr = lines_arr.uniq
    final_string = stops.join(", ") + " (" + lines_arr.join(",") + ")"
    return final_string
  end

  def get_pretty_price
    self.price.to_s.reverse.scan(/.{1,3}/).join(" ").reverse
  end

  def get_matching_subscribers

    # 1. Surface, price and rooms_number criterias, floor
    floor.nil? ? virtual_floor = 1000 : virtual_floor = floor
    subs_query = Subscriber.where(
      is_active: true,
      max_price: price..Float::INFINITY,
      min_surface: Float::INFINITY..surface,
      min_rooms_number: Float::INFINITY..rooms_number,
      min_floor: Float::INFINITY..virtual_floor,
    )

    # 2. Area criteria
    subs = []
    subs_query.each do |sub|
      sub.areas.each do |sub_area|
        subs.push(sub) if sub_area == area
      end
    end
    # 3. elevator criteria
    final_subs = []
    if has_elevator === false && floor != nil
      subs.each do |sub|
        sub.min_elevator_floor > floor ? final_subs.push(sub) : nil
      end
    else
      final_subs = subs
    end

    return final_subs
  end

  # Broadcast property to all matching subscribers
  def broadcast
    m = Manychat.new
    subs = self.get_matching_subscribers
    subs.each do |sub|
      m.send_single_property_card(sub, self)
    end
  end

  def self.unprocessed
    self.where(has_been_processed: false)
  end

  private

  def image_array_validator
    self.images.push(DEFAULT_IMG_URL) if self.images.blank?
  end

  def image_link_validator
    correct_image = []
    self.images.each do |image|
      correct_image.push(image) if image.match(/https?:\/\/[\S]+/i).is_a?(MatchData)
    end
    self.images = correct_image
  end
end
