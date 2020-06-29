class HunterSearch < ApplicationRecord
  belongs_to :hunter
  has_many :hunter_search_areas
  has_many :areas, through: :hunter_search_areas

  def get_matching_properties(limit = 24)
    props = Property.where(
      price: self.min_price..self.max_price,
      rooms_number: self.min_rooms_number..Float::INFINITY,
      surface: self.min_surface..Float::INFINITY,
    ).order(id: :desc).limit(200)

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
      break if prop_array.length == limit
    end
    return prop_array
  end

  def is_matching_property?(args, subs_areas)
    ##We receive args in an array with this index [id, rooms_number, surface, price, floor, area_id, elevator]
    test_rooms_number = is_matching_property_rooms_number(args[1])
    test_surface = is_matching_property_surface(args[2])
    test_price = is_matching_property_price(args[3])
    test_floor = is_matching_property_floor(args[4])
    test_areas = is_matching_property_area(args[5], subs_areas)
    test_elevator = is_matching_property_elevator_floor(args[4], args[6])
    test_sqm = is_matching_max_sqm_price(args[3], args[2])

    test_price && test_surface && test_rooms_number && test_floor && test_elevator && test_areas && test_sqm ? true : false
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
    ((price/surface).round(0).to_i <= self.max_sqm_price ? true : false) if !self.max_sqm_price.nil? && surface != 0
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
      if !has_elevator.nil?
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

end
