require "dotenv/load"

class Subscriber < ApplicationRecord

  ## REVOIR LES VALIDATEURS

  belongs_to :broker, optional: true

  has_many :selected_areas
  has_many :areas, through: :selected_areas

  has_many :favorites
  has_many :fav_properties, through: :favorites, source: :property

  has_many :subscriber_sequences
  has_many :sequences, through: :subscriber_sequences

  has_many :subscriber_statuses
  has_many :statuses, through: :subscriber_statuses


  ########################
  # 1 - Business methods
  ########################

  def is_matching_property?(args, subs_areas)
    is_matching_property_rooms_number(args["rooms_number"]) &&
    is_matching_property_surface(args["surface"]) &&
    is_matching_property_price(args["price"]) &&
    is_matching_property_floor(args["floor"]) &&
    is_matching_property_area(args["area_id"], subs_areas) &&
    is_matching_max_sqm_price(args["price"], args["surface"]) &&
    is_matching_property_elevator_floor(args["floor"], args["has_elevator"]) &&
    is_matching_exterior?(args["has_terrace"], args["has_garden"], args["has_balcony"]) &&
    is_matching_property_last_floor(args["is_last_floor"]) &&
    is_matching_property_new_construction(args["is_new_construction"])
  end

  def is_client?
    is_client = false
    statuses_scoped = ["form_filled", "chatbot_invite_sent", "onboarding_started", "onboarded"]

    # 1 • On regarde s'il y a un SubscriberStatus (nouveaux users)
    subscriber_statuses = SubscriberStatus.where(subscriber: self)
    if !subscriber_statuses.empty? 
      subscriber_statuses.each do |ss|
        if statuses_scoped.include?(ss.status.name)
          is_client = true 
        end
      end
    else 
      # 2 • Sinon on regarde directement l'atribut status (old users)
      if statuses_scoped.include?(self.status)
        is_client = true
      end
    end
    return is_client
  end


  def has_interacted(last_interaction, day_range)
    response = false
    parsed_last_interaction = Time.parse(last_interaction)
    if Time.now < parsed_last_interaction + day_range.days
      response = true
    end
    return response
  end

  # a refacto avec Max
  def get_x_last_props(max_number)
    attrs = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link link)
    props = 
      Property.where(area: self.areas)
      .where('price <= ? AND surface >= ? AND rooms_number >= ?', self.max_price, self.min_surface, self.min_rooms_number)
      .order(id: :desc)
      .limit(200)
      .pluck(*attrs).map { |p| attrs.zip(p).to_h }
    props_to_send = []
    subs_areas = self.areas.ids
    props.each do |prop|
      props_to_send.push(prop["id"]) if self.is_matching_property?(prop, subs_areas)
      break if props_to_send.length == max_number.to_i
    end
    return props_to_send
  end

  def update_areas(areas_ids)
    selected_areas = self.areas.pluck(:id)
    areas_ids.map! {|id| id.to_i }
    areas_to_destroy = selected_areas.reject {|x| areas_ids.include?(x)}
    self.selected_areas.where(area_id: areas_to_destroy).destroy_all unless areas_to_destroy.empty?
    areas_to_add = areas_ids.reject {|x| selected_areas.include?(x)}
    areas_to_add.each { |area_id| SelectedArea.create(subscriber_id: self.id, area_id: area_id) } unless areas_to_add.empty?
  end

  def get_props_in_lasts_x_days(x_previous_days)
    start_date = Time.now.in_time_zone("Europe/Paris") - x_previous_days.to_i.days
    attrs = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link)
    props = Property
      .where("created_at >= ?", start_date)
      .pluck(*attrs).map { |p| attrs.zip(p).to_h }

    props_to_send = []
    subs_areas = self.areas.ids

    props.each do |prop|
      props_to_send.push(prop["id"]) if self.is_matching_property?(prop, subs_areas)
    end

    return props_to_send
  end

  def get_morning_props
    now = DateTime.now.in_time_zone("Europe/Paris")
    start_date = DateTime.new(now.year, now.month, now.day, 22, 0, 0, now.zone) - 1
    end_date = DateTime.new(now.year, now.month, now.day, 9, 0, 0, now.zone)
    attrs = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link)
    props = Property
      .where("created_at BETWEEN ? AND ?", start_date, end_date)
      .pluck(*attrs).map { |p| attrs.zip(p).to_h }

    props_to_send = []

    subs_areas = self.areas.ids
    props.each do |prop|
      props_to_send.push(prop["id"]) if self.is_matching_property?(prop, subs_areas)
      break if props_to_send.length == 10
    end
    return props_to_send
  end

  # A voir ... (util pour Etienne ?)
  def notify_broker_trello(comment)
    Trello.new.add_comment_to_user_card(self, comment)
  end

  def handle_new_lead_gen
    # broker = Broker.get_current_lead_gen
    broker = Broker.find_by(email: "etienne@hellodingdong.com")
    self.update(broker: broker, is_blocked: true)
    Trello.new.add_lead_on_etienne_trello(self)
    BrokerMailer.new_lead(self.id).deliver_now
  end


  ########################
  # 2 - Core methods
  ########################

  # TRELLO METHODS

  def trello_description
    desc = ""
    desc += "**CONTACT** \u000A Tél: #{self.phone} \u000A Email: #{self.email}\u000A"
    desc += "\u000A**PROJET**\u000A"
    desc += "\u000A**FINANCEMENT**\u000A"
    desc += "\u000A**NOTES**\u000A"
    desc += "\u000A\u000A---\u000A\u000A"
    desc += trello_summary
  end

  def trello_summary
    desc = ""
    desc += "**#{self.get_fullname.upcase}**"
    desc += "\u000A**Projet d'achat** : #{self.project_type}"
    desc += "\u000A**Budget Maximum** : #{self.max_price.to_s.reverse.gsub(/...(?=.)/, '\& ').reverse} €"
    desc += "\u000A**Surface Minimum ** : #{self.min_surface} m2"
    desc += "\u000A**Nombre de pièces minimum ** : #{self.min_rooms_number}"
    desc += "\u000A**Arrondissements** : #{self.get_areas_list}"
    desc += "\u000A**Critère(s) spécifique(s)** : #{self.specific_criteria}" if !self.specific_criteria.nil?
    desc += "\u000A**Question(s) additionelle(s)** : #{self.additional_question}" if !self.additional_question.nil?
    desc += "\u000A\u000A**#{self.get_fullname} a déclaré ne pas avoir Messenger**" if !self.has_messenger
    desc += "\u000A\u000A*Inscription chez DingDong : #{Time.now.in_time_zone("Paris").strftime("%d/%m/%Y - %H:%M")}*"
  end

  def get_fullname
    return self.firstname + " " + self.lastname
  end

  def get_areas_list
    areas = ""
    self.areas.each do |area|
      areas += area.name + ", "
    end
    return areas
  end

  def get_areas
    areas = []
    self.areas.each do |area|
      areas.push(area.name)
    end
    return areas
  end

  def get_areas_list
    list = ""
    self.areas.each do |area|
      list = list + ";" + area.name
    end
    list[0] = ""
    return list
  end

  def get_edit_path
    return ENV["BASE_URL"] + "subscribers/" + self.id.to_s + "/edit"
  end

  ########################
  # 3 - Class methods
  ########################

  def self.active
    self.where(is_active: true)
  end

  def self.active_and_not_blocked
    self.where(is_active: true, is_blocked: [nil, false])
  end

  def self.not_blocked
    self.where(is_blocked: [nil, false])
  end
  
  def self.inactive
    self.where(is_active: false)
  end

  def self.facebook_id(facebook_id)
    self.where(facebook_id: facebook_id)
  end

  private

  ###################
  # Matching methods
  ###################

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

  def is_matching_max_sqm_price(price, surface)
    if !self.max_sqm_price.nil? && surface != 0
      ((price/surface).round(0).to_i <= self.max_sqm_price ? true : false) 
    else
      true 
    end
  end

  def is_matching_property_surface(surface)
    surface >= self.min_surface unless self.min_surface.nil?
  end

  def is_matching_property_rooms_number(rooms_number)
    rooms_number.to_i >= self.min_rooms_number unless self.min_rooms_number.nil?
  end

  def is_matching_property_floor(floor)
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

  def is_matching_property_elevator_floor(floor, has_elevator)
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

  def is_matching_property_area(area_id, sub_areas = self.areas.ids)
    sub_areas.include?(area_id)
  end

  def is_matching_property_new_construction(is_new_construction)
    !self.new_construction && is_new_construction ? false : true
  end

# A voir ...
  def notify_broker_if_max_price_is_changed
    if !previous_changes["max_price"].nil? && !self.broker.nil? && !self.trello_id_card.nil?
      old_price = previous_changes["max_price"][0]
      new_price = previous_changes["max_price"][1]
      self.notify_broker_trello("Prix d'achat max modifié. Changé de #{old_price} € à #{new_price} €")
    end
  end

  # A vérifier mais useless normalement
  def attribute_adequate_broker(form_type = "regular")
    if self.broker.nil?
      shift_type = form_type == "subscription" ? "subscription" : "regular"
      self.update(broker: Broker.get_current(shift_type))
    end
  end
end
