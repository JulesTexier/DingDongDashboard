class Research < ApplicationRecord
  belongs_to :subscriber, optional: true
  belongs_to :hunter, optional: true

  has_many :research_areas
  has_many :areas, through: :research_areas

  has_many :saved_properties
  has_many :properties, through: :saved_properties

  validate :correct_association

  def last_matching_properties(limit = 100, max_scope = 500)
    matched_props_ids = []
    areas_ids = ResearchArea.where(research: self).pluck(:area_id)
    attrs = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link)      
    properties = Property.where('price <= ? AND surface >= ? AND rooms_number >= ?', self.max_price, self.min_surface, self.min_rooms_number).where(area: areas_ids).order(id: :desc).limit(max_scope).pluck(*attrs).map { |p| attrs.zip(p).to_h }
    areas_ids = self.areas.ids
    properties.each do |property|
      matched_props_ids.push(property["id"]) if matching_property?(property, areas_ids)
      break if matched_props_ids.length == limit
    end
    return Property.where(id: matched_props_ids).order(id: :desc)
  end

  def matching_property?(args, areas)
    matching_property_rooms_number?(args["rooms_number"]) &&
    matching_property_surface?(args["surface"]) &&
    matching_property_price?(args["price"]) &&
    matching_property_floor?(args["floor"]) &&
    matching_property_area?(args["area_id"], areas) &&
    matching_max_sqm_price?(args["price"], args["surface"]) &&
    matching_property_elevator_floor?(args["floor"], args["has_elevator"]) &&
    matching_exterior?(args["has_terrace"], args["has_garden"], args["has_balcony"]) &&
    matching_property_last_floor?(args["is_last_floor"]) &&
    matching_property_new_construction?(args["is_new_construction"])
  end

  def update_research_areas(areas_ids)
    selected_areas = self.areas.pluck(:id)
    areas_ids.map! do |area_id|
      area_id.include?("GlobalZone") ? Area.where(zone: area_id.gsub("GlobalZone - ", "")).pluck(:id) : area_id
    end
    cleaned_area_array = areas_ids.flatten
    cleaned_area_array.map! {|id| id.to_i }
    cleaned_area_array.uniq!
    areas_to_destroy = selected_areas.reject {|x| cleaned_area_array.include?(x)}
    self.research_areas.where(area_id: areas_to_destroy).destroy_all unless areas_to_destroy.empty?
    areas_to_add = cleaned_area_array.reject {|x| selected_areas.include?(x)}
    areas_to_add.each { |area_id| ResearchArea.create(research_id: self.id, area_id: area_id) } unless areas_to_add.empty?
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


  ##################################
  ## HUNTER METHODS FOR BROADCAST ##
  ##################################

  def self.live_broadcasted
    hunters_id = Hunter.where(live_broadcast: true).pluck(:id)
    Research.where(hunter_id: hunters_id)
  end

  def self.not_live_broadcasted
    hunters_id = Hunter.where.not(live_broadcast: true).pluck(:id)
    Research.where(hunter_id: hunters_id)
  end
  
  private

  ####################
  # MATCHING METHODS #
  ####################

  def matching_property_max_price?(price)
    price <= self.max_price if !self.max_price.nil?
  end

  def matching_property_min_price?(price)
    if !self.min_price.nil?
      price >= self.min_price
    else
      true
    end
  end

  def matching_property_price?(price)
    matching_property_max_price?(price) && matching_property_min_price?(price)
  end

  def matching_max_sqm_price?(price, surface)
    if !self.max_sqm_price.nil? && surface != 0
      (price / surface).round(0) <= self.max_sqm_price
    else
      true 
    end
  end

  def matching_property_surface?(surface)
    surface >= self.min_surface unless self.min_surface.nil?
  end

  def matching_property_rooms_number?(rooms_number)
    rooms_number.to_i >= self.min_rooms_number unless self.min_rooms_number.nil?
  end

  def matching_property_floor?(floor)
    if self.min_floor.nil?
      true
    else
      if !floor.nil?
        floor.to_i >= self.min_floor unless self.min_floor.nil?
      else
        true
      end
    end
  end

  def matching_property_elevator_floor?(floor, has_elevator)
    if self.min_elevator_floor.nil?
      return true
    else
      if !has_elevator.nil?
        if has_elevator
          return true
        else
          floor.to_i < self.min_elevator_floor.to_i
        end
      else
        return true
      end
    end
  end

  def matching_exterior?(terrace, garden, balcony)
    if self.terrace || self.balcony || self.garden #At least one exterior criteria
      if (self.terrace && matching_property_terrace?(terrace)) || (self.balcony && matching_property_balcony?(balcony)) || (self.garden && matching_property_garden?(garden))
        return true 
      else
        return false 
      end
    else # Else; no testing => returning true
      return true
    end
  end

  def matching_property_terrace?(terrace)
    self.terrace ? !terrace.nil? && terrace : true
  end

  def matching_property_garden?(garden)
    self.garden ? !garden.nil? && garden : true
  end

  def matching_property_balcony?(balcony)
    self.balcony ? !balcony.nil? && balcony : true
  end

  def matching_property_last_floor?(last_floor)
    self.last_floor ? !last_floor.nil? && last_floor : true
  end

  def matching_property_area?(area_id, sub_areas = self.areas.ids)
    sub_areas.include?(area_id)
  end

  def matching_property_new_construction?(is_new_construction)
    !self.new_construction && is_new_construction ? false : true
  end

  def correct_association
    case
    when self.hunter.nil? && self.subscriber.nil?
      errors.add(:research, "should belong to hunter or subscriber")
    when !self.hunter.nil? && !self.subscriber.nil? 
      errors.add(:research, "shouldn't belong to hunter AND subscriber") 
    end
  end
end
