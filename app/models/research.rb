class Research < ApplicationRecord
  belongs_to :subscriber, optional: true
  belongs_to :hunter, optional: true

  has_many :research_areas
  has_many :areas, through: :research_areas

  validate :correct_association

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
  ####################
  # MATCHING METHODS #
  ####################
  
  private

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

  private 

  def correct_association
    case
    when self.hunter.nil? && self.subscriber.nil?
      errors.add(:research, "should belong to hunter or subscriber")
    when !self.hunter.nil? && !self.subscriber.nil? 
      errors.add(:research, "shouldn't belong to hunter AND subscriber") 
    end
  end
end
