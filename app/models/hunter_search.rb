class HunterSearch < ApplicationRecord
  belongs_to :hunter
  has_many :hunter_search_areas
  has_many :areas, through: :hunter_search_areas

  def get_matching_properties
    props = Property.where(
      price: Float::INFINITY..self.max_price,
      rooms_number: self.rooms_number..Float::INFINITY,
      surface: self.surface..Float::INFINITY,
    )

    prop_array = []
    props.each do |prop|
      self.areas.each do |area|
        if prop.area == area
          if prop.has_elevator == false && prop.floor != nil
            prop_array.push(prop) if self.min_elevator_floor > prop.floor
          else
            prop_array.push(prop)
          end
        end
      end
    end
    return prop_array
  end

  

  def get_pretty_price
    self.max_price.to_s.reverse.scan(/.{1,3}/).join(" ").reverse
  end
end
