class Research < ApplicationRecord
  belongs_to :subscriber
  belongs_to :agglomeration
  has_many :research_areas
  has_many :areas, through: :research_areas

  has_many :saved_properties
  has_many :properties, through: :saved_properties

  #############################
  ## CONSTANT FOR ATTRIBUTES ##
  #############################

  ATTRS = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link flat_type)

  def last_matching_properties(limit = 100, max_scope = 500)
    properties = Property
    .where('price <= ? AND surface >= ? AND rooms_number >= ?', 
    self.max_price, 
    self.min_surface, 
    self.min_rooms_number)
    .where(area: self.areas.ids)
    .order(id: :desc)
    .limit(max_scope)
    .pluck(*ATTRS)
    .map { |p| ATTRS.zip(p).to_h }
    matched_props_ids = []
    areas_ids = self.areas.ids
    properties.each do |property|
      matched_props_ids.push(property["id"]) if matching_property?(property, areas_ids)
      break if matched_props_ids.length == limit
    end
    Property.where(id: matched_props_ids).order(id: :desc)
  end

  def morning_properties
    now = DateTime.now.in_time_zone("Europe/Paris")
    start_date = DateTime.new(now.year, now.month, now.day, 22, 0, 0, now.zone) - 1
    end_date = DateTime.new(now.year, now.month, now.day, 9, 0, 0, now.zone)
    props = Property
      .where("created_at BETWEEN ? AND ?", start_date, end_date)
      .order(id: :desc)
      .pluck(*ATTRS)
      .map { |p| ATTRS.zip(p).to_h }
    props_to_send = []
    areas_ids = self.areas.ids
    props.each do |prop|
      props_to_send.push(prop["id"]) if self.matching_property?(prop, areas_ids)
      break if props_to_send.length == 10
    end
    props_to_send
  end

  def properties_last_x_days(x_previous_days)
    start_date = Time.now.in_time_zone("Europe/Paris") - x_previous_days.to_i.days
    props = Property
      .where("created_at >= ?", start_date)
      .pluck(*ATTRS)
      .map { |p| ATTRS.zip(p).to_h }
    props_to_send = []
    areas_ids = self.areas.ids
    props.each do |prop|
      props_to_send.push(prop["id"]) if self.matching_property?(prop, areas_ids)
    end
    props_to_send
  end

  def last_x_properties(max_number)
    props = Property
      .where(area: self.areas)
      .where('price <= ? AND surface >= ? AND rooms_number >= ?', self.max_price, self.min_surface, self.min_rooms_number)
      .order(id: :desc)
      .limit(200)
      .pluck(*ATTRS)
      .map { |p| ATTRS.zip(p).to_h }
    props_to_send = []
    areas_ids = self.areas.ids
    props.each do |prop|
      props_to_send.push(prop["id"]) if self.matching_property?(prop, areas_ids)
      break if props_to_send.length == max_number.to_i
    end
    props_to_send
  end

  ################################
  ## PUBLIC MATCHING ALGORITHMS ##
  ################################

  def matching_property?(args, areas)
    is_matching = matching_property_rooms_number?(args["rooms_number"]) &&
    matching_property_surface?(args["surface"]) &&
    matching_property_price?(args["price"]) &&
    matching_property_area?(args["area_id"], areas) &&
    matching_max_sqm_price?(args["price"], args["surface"]) &&
    matching_exterior?(args["has_terrace"], args["has_garden"], args["has_balcony"]) &&
    matching_property_new_construction?(args["is_new_construction"]) && 
    matching_property_flat_type?(args["flat_type"])

    if is_matching && ["Appartement", "N/C"].include?(args["flat_type"])
      is_matching = matching_property_elevator_floor?(args["floor"], args["has_elevator"]) &&
      matching_property_floor?(args["floor"]) &&
      matching_property_last_floor?(args["is_last_floor"])
    end
    
    return is_matching
  end

  def update_research_areas(areas_ids)
    selected_areas = self.areas.pluck(:id)
    modified_array = []
    areas_ids.each do |area_id|
      modified_array.push(Department.find(area_id.gsub("department ", "").to_i).areas.pluck(:id)) if area_id.include?("department")
      modified_array.push(area_id.gsub("area ", "").to_i) if area_id.include?("area")
    end
    cleaned_area_array = modified_array.flatten
    cleaned_area_array.map! {|id| id.to_i }
    cleaned_area_array.uniq!
    areas_to_destroy = selected_areas.reject {|x| cleaned_area_array.include?(x)}
    self.research_areas.where(area_id: areas_to_destroy).delete_all unless areas_to_destroy.empty?
    areas_to_add = cleaned_area_array.reject {|x| selected_areas.include?(x)}
    areas_to_import = []
    areas_to_add.each { |area_id| areas_to_import << ResearchArea.new(research_id: self.id, area_id: area_id) } unless areas_to_add.empty?
    ResearchArea.import areas_to_import
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

  def average_results_estimation(nb_days = 7)
    props = Property
      .where('created_at > ? ', Time.now - nb_days.days)
      .where(area: self.areas)
      .where('price <= ? AND surface >= ? AND rooms_number >= ?', self.max_price, self.min_surface, self.min_rooms_number)
      .order(id: :desc)
      .limit(1000)
      .pluck(*ATTRS).map { |p| ATTRS.zip(p).to_h }
    matching_props = []
    props.each do |prop|
      matching_props.push(prop["id"]) if self.matching_property?(prop, self.areas.ids)
    end
    average = matching_props.count/nb_days
    return [(average*0.8).round, (average*1.2).round]
  end

  ###########################
  ## METHODS FOR BROADCAST ##
  ###########################

  def self.active_subs_research_messenger
    self.includes(:subscriber)
      .where.not(subscribers: { id: nil, facebook_id: nil })
      .where(subscribers: { is_active: true, is_blocked: [false, nil], messenger_flux: true, email_flux: [false, nil] })
  end

  def self.active_subs_research_email
    self.includes(:subscriber)
      .where.not(subscribers: { id: nil })
      .where(subscribers: { is_active: true, is_blocked: [false, nil], email_flux: true, messenger_flux: [false, nil], email_confirmed: true })
  end
  
  def get_areas_list
    areas = ""
    self.areas.each do |area|
      areas += area.name + ", "
    end
    return areas
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

  def matching_property_flat_type?(flat_type)
    if flat_type == "Maison"
      self.home_type
    elsif flat_type == "Appartement"
      self.apartment_type
    elsif flat_type == "N/C"
      self.home_type && !self.apartment_type ? false : true
    end
  end
end
