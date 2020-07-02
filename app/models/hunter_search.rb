class HunterSearch < ApplicationRecord
  belongs_to :hunter
  has_many :hunter_search_areas
  has_many :areas, through: :hunter_search_areas

  has_many :selections
  has_many :properties, through: :selections, source: :property

  def get_matching_properties(limit = 24)
    min_price = self.min_price.nil? ? 0 : self.min_price
    props = Property.where(
      price: min_price..self.max_price,
      rooms_number: self.min_rooms_number..Float::INFINITY,
      surface: self.min_surface..Float::INFINITY,
    ).order(id: :desc).limit(200)

    prop_array = []
    props.each do |prop|
      if self.is_matching_max_sqm_price(prop.price, prop.surface)
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
      break if prop_array.length == limit
    end
    return prop_array
  end

  def is_matching_property?(args, subs_areas)
    is_matching_property_rooms_number(args["rooms_number"]) &&
    is_matching_property_surface(args["surface"]) &&
    is_matching_property_price(args["price"]) &&
    is_matching_property_floor(args["floor"]) &&
    is_matching_property_area(args["area_id"], subs_areas) &&
    is_matching_property_elevator_floor(args["floor"], args["has_elevator"]) &&
    is_matching_max_sqm_price(args["price"], args["surface"])
  end

  def is_matching_property_max_price(price)
    (price <= self.max_price ? true : false) if !self.max_price.nil?
  end

  def is_matching_property_min_price(price)
    (price >= self.min_price ? true : false) if !self.min_price.nil?
  end

  def is_matching_property_price(price)
    is_matching_property_max_price(price) && is_matching_property_min_price(price)
  end

  def is_matching_property_surface(surface)
    (surface >= self.min_surface ? true : false) if !self.min_surface.nil?
  end

  def is_matching_max_sqm_price(price, surface)
    if !self.max_sqm_price.nil? && surface != 0
      ((price/surface).round(0).to_i <= self.max_sqm_price ? true : false) 
    else
      true 
    end
  end

  def is_matching_property_rooms_number(rooms_number)
    (rooms_number.to_i >= self.min_rooms_number ? true : false) if !self.min_rooms_number.nil?
  end
  
  def is_matching_property_floor(floor)
    if self.min_floor.nil?
      return true
    else
      if !floor.nil?
        (floor.to_i >= self.min_floor ? true : false) if !self.min_floor.nil?
      else
        return true
      end
    end
  end

  def is_matching_property_elevator_floor(floor, has_elevator)
    if self.min_elevator_floor.nil?
      return true
    else
      if !has_elevator.nil? && !floor.nil?
        if has_elevator
          return true
        else
          floor.to_i < self.min_elevator_floor.to_i ? true : false
        end
      else
        return true
      end
    end
  end

  def is_matching_property_area(area_id, search_areas = self.areas.ids)
    search_areas.include?(area_id) ? true : false
  end

  def get_pretty_price(edge)
    if edge == "max"
      self.max_price.to_s.reverse.scan(/.{1,3}/).join(" ").reverse
    else
      self.min_price.to_s.reverse.scan(/.{1,3}/).join(" ").reverse
    end
  end

  def get_pretty_title
    return "max. #{self.get_pretty_price("max")} € - min. #{self.min_surface} m2 - min. #{self.min_rooms_number} pce"
  end

  def self.live_broadcasted
    hunters_id = Hunter.where(live_broadcast: true).pluck(:id)
    HunterSearch.where(hunter_id: hunters_id)
  end

  def self.not_live_broadcasted
    hunters_id = Hunter.where.not(live_broadcast: true).pluck(:id)
    HunterSearch.where(hunter_id: hunters_id)
  end

end
