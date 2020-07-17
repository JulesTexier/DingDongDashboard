class HunterSearch < ApplicationRecord
  belongs_to :hunter
  has_many :hunter_search_areas
  has_many :areas, through: :hunter_search_areas

  has_many :selections
  has_many :properties, through: :selections, source: :property

  def get_matching_properties(limit = 100, max_scope = 500)
    matched_props_ids = []
    areas_ids = HunterSearchArea.where(hunter_search: self).pluck(:area_id)
    attrs = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link)      
    properties = Property.where('price <= ? AND surface >= ? AND rooms_number >= ?', self.max_price, self.min_surface, self.min_rooms_number).where(area: areas_ids).last(max_scope).pluck(*attrs).map { |p| attrs.zip(p).to_h }
    areas_ids = self.areas.ids
    properties.each do |property|
      matched_props_ids.push(property["id"]) if is_matching_property?(property, areas_ids)
      break if matched_props_ids.length == limit
    end
    return Property.where(id: matched_props_ids)
  end

  def update_hunter_search_areas(areas_ids)
    selected_areas = self.areas.pluck(:id)
    areas_ids.map! {|id| id.to_i }
    areas_to_destroy = selected_areas.reject {|x| areas_ids.include?(x)}
    self.hunter_search_areas.where(area_id: areas_to_destroy).destroy_all unless areas_to_destroy.empty?
    areas_to_add = areas_ids.reject {|x| selected_areas.include?(x)}
    areas_to_add.each { |area_id| HunterSearchArea.create(hunter_search_id: self.id, area_id: area_id) } unless areas_to_add.empty?
  end

  def is_matching_property?(args, subs_areas)
    is_matching_property_rooms_number(args["rooms_number"]) &&
    is_matching_property_surface(args["surface"]) &&
    is_matching_property_price(args["price"]) &&
    is_matching_property_floor(args["floor"]) &&
    is_matching_property_area(args["area_id"], subs_areas) &&
    is_matching_property_elevator_floor(args["floor"], args["has_elevator"]) &&
    is_matching_max_sqm_price(args["price"], args["surface"]) &&
    is_matching_exterior?(args["has_terrace"], args["has_garden"], args["has_balcony"]) &&
    is_matching_property_last_floor(args["is_last_floor"])
  end

  def is_matching_property_max_price(price)
    (price <= self.max_price ? true : false) if !self.max_price.nil?
  end

  def is_matching_property_min_price(price)
    if !self.min_price.nil?
      (price >= self.min_price ? true : false) 
    else
      true
    end
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

  def is_matching_exterior?(terrace, garden, balcony)
    if self.terrace || self.balcony || self.garden #At least one exterior criteria
      if (self.terrace && is_matching_property_terrace(terrace)) || (self.balcony && is_matching_property_balcony(balcony)) || (self.garden && is_matching_property_garden(garden))
        return true 
      else
        return false 
      end
    else # Esle; no testing => returning true
      return true
    end
  end

  def is_matching_property_terrace(terrace)
    self.terrace ? !terrace.nil? && terrace : true
  end

  def is_matching_property_garden(garden)
    self.garden ? !garden.nil? && garden : true
  end

  def is_matching_property_balcony(balcony)
    self.balcony ? !balcony.nil? && balcony : true
  end

  def is_matching_property_last_floor(last_floor)
    self.last_floor ? !last_floor.nil? && last_floor : true
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
