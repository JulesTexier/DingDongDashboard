require "dotenv/load"

class Subscriber < ApplicationRecord
  # after_update :handle_onboarding
  after_update :notify_broker_if_max_price_is_changed

  # validates_uniqueness_of :facebook_id, :case_sensitive => false
  # validates :facebook_id, presence: true
  # validates :email, presence: false, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "email is not valid" }
  # validates :phone
  validates :firstname, presence: true, unless: -> { status == "new_lead" }
  validates :lastname, presence: true, unless: -> { status == "new_lead" }

  belongs_to :broker, optional: true

  has_many :selected_areas
  has_many :areas, through: :selected_areas

  has_many :selected_districts
  has_many :districts, through: :selected_districts

  has_many :favorites
  has_many :fav_properties, through: :favorites, source: :property

  has_many :subscriber_sequences
  has_many :sequences, through: :subscriber_sequences

  has_many :subscriber_statuses
  has_many :statuses, through: :subscriber_statuses

  def is_client?
    case self.status
    when "form_filled", "chatbot_invite_sent", "onboarding_started", "onboarded"
      true
    else
      false
    end
  end

  def get_areas_list
    list = ""
    self.areas.each do |area|
      list = list + ";" + area.name
    end
    list[0] = ""
    return list
  end

  def get_districts_list
    list = ""
    self.districts.each do |district|
      list = list + ";" + district.name
    end
    list[0] = ""
    return list
  end

  def get_edit_path
    return ENV["BASE_URL"] + "subscribers/" + self.id.to_s + "/edit"
  end

  def is_matching_property?(args, subs_areas)
    ##We receive args in an array with this index [id, rooms_number, surface, price, floor, area_id, elevator]
    test_rooms_number = is_matching_property_rooms_number(args[1])
    test_surface = is_matching_property_surface(args[2])
    test_price = is_matching_property_price(args[3])
    test_floor = is_matching_property_floor(args[4])
    test_areas = is_matching_property_area(args[5], subs_areas)
    test_elevator = is_matching_property_elevator_floor(args[4], args[6])

    test_price && test_surface && test_rooms_number && test_floor && test_elevator && test_areas ? true : false
  end

  def has_interacted(last_interaction, day_range)
    response = false
    parsed_last_interaction = Time.parse(last_interaction)
    if Time.now < parsed_last_interaction + day_range.days
      response = true
    end
    return response
  end

  def get_x_last_props(max_number)
    props = Property
      .order(id: :desc)
      .limit(1000)
      .pluck(:id, :rooms_number, :surface, :price, :floor, :area_id, :has_elevator)
    props_to_send = []
    subs_areas = self.areas.ids
    props.each do |prop|
      props_to_send.push(prop[0]) if self.is_matching_property?(prop, subs_areas)
      break if props_to_send.length == max_number.to_i
    end

    return props_to_send
  end

  def get_props_in_lasts_x_days(x_previous_days)
    start_date = Time.now.in_time_zone("Europe/Paris") - x_previous_days.to_i.days

    props = Property
      .where("created_at >= ?", start_date)
      .pluck(:id, :rooms_number, :surface, :price, :floor, :area_id, :has_elevator)

    props_to_send = []
    subs_areas = self.areas.ids

    ##We pass args in an array with this index [id, rooms_number, surface, price, floor, area_id, elevator]
    props.each do |prop|
      props_to_send.push(prop[0]) if self.is_matching_property?(prop, subs_areas)
    end

    return props_to_send
  end

  def get_morning_props
    now = DateTime.now.in_time_zone("Europe/Paris")
    start_date = DateTime.new(now.year, now.month, now.day, 22, 0, 0, now.zone) - 1
    end_date = DateTime.new(now.year, now.month, now.day, 9, 0, 0, now.zone)

    props = Property
      .where("created_at BETWEEN ? AND ?", start_date, end_date)
      .pluck(:id, :rooms_number, :surface, :price, :floor, :area_id, :has_elevator)

    props_to_send = []

    subs_areas = self.areas.ids
    props.each do |prop|
      props_to_send.push(prop[0]) if self.is_matching_property?(prop, subs_areas)
      break if props_to_send.length == 10
    end
    return props_to_send
  end

  def get_areas
    areas = []
    self.areas.each do |area|
      areas.push(area.name)
    end
    return areas
  end

  def self.active
    self.where(is_active: true)
  end

  def self.inactive
    self.where(is_active: false)
  end

  def self.facebook_id(facebook_id)
    self.where(facebook_id: facebook_id)
  end

  def notify_broker_trello(comment)
    Trello.new.add_comment_to_user_card(self, comment)
  end

  # TRELLO METHODS
  def trello_description
    desc = ""
    desc += "**CONTACT** \u000A Tél: #{self.phone} \u000A Email: #{self.email}\u000A"
    desc += "\u000A**PROJET**\u000A"
    desc += "\u000A**FINANCEMENT**\u000A"
    desc += "\u000A**CLIENTE**\u000A"
    desc += "\u000A**NOTES**\u000A"
    desc += "\u000A**QU’AVEZ PENSE DE CE RDV (inscription) :**\u000A"
    desc += "\u000A**SUITE RDV COURTAGE :**\u000A"
    desc += "\u000A**QU’AVEZ PENSE DE CE RDV (courtage) :**\u000A"
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
    desc += "\u000A\u000A*Inscription chez DingDong : #{self.created_at.in_time_zone("Paris").strftime("%d/%m/%Y - %H:%M")}*"
  end

  def get_chatbot_link
    return "https://m.me/HiDingDong?ref=hello--#{self.id}"
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

  def get_initial_areas
    areas_name = []
    if !self.initial_areas.nil?
      self.initial_areas.split(",").each do |area|
        areas_name.push(Area.find(area).name)
      end
    end
    return areas_name.join(", ")
  end

  def add_initial_areas(areas_ad_list)
    if !areas_ad_list.nil?
      areas_ad_list.split(',').each do |area_id|
        if !Area.find(area_id).nil? && SelectedArea.where(subscriber: self, area_id: area_id).empty?
          self.areas << Area.find(area_id)
        end
      end
    end
  end

  def onboarding_old_user
    self.update(has_messenger: true, broker: Broker.find_by(trello_username: "etienne_dingdong"))
    trello = Trello.new
    trello.add_new_user_on_trello(self)
    trello.add_label_old_user(self)
  end

  def handle_form_filled(subscriber_params)
    has_been_updated = self.update(subscriber_params)
    self.add_initial_areas(subscriber_params[:initial_areas])
    SubscriberStatus.create(subscriber: self, status: Status.find_by(name: "form_filled"))
    if self.project_type.downcase.include?("chasseur")
      SubscriberStatus.create(subscriber: self, status: Status.find_by(name: "real_estate_hunter"))
      onboarding_hunter
    elsif !self.has_messenger
      SubscriberStatus.create(subscriber: self, status: Status.find_by(name: "has_not_messenger"))
      onboarding_no_messenger
    elsif self.broker.nil?
      onboarding_broker
    end
    return has_been_updated
  end

  private

  def handle_duplicate
    self.update(status: "duplicates")
    PostmarkMailer.send_user_dulicate_email(self).deliver_now if !self.email.nil?
  end

  def onboarding_hunter
    # Send email to lead with Max in C/C
    PostmarkMailer.send_onboarding_hunter_email(self).deliver_now if !self.email.nil?
  end

  def onboarding_no_messenger
    # Send email to lead with explainations
    PostmarkMailer.send_email_to_lead_with_no_messenger(self).deliver_now
  end

  def onboarding_broker
    attribute_adequate_broker
    # self.update(broker: Broker.get_current_broker) if self.broker.nil?
    trello = Trello.new
    sms = SmsMode.new
    if ENV["RAILS_ENV"] == "production"
      if trello.add_new_user_on_trello(self)
        # self.broker.send_email_notification(self)
        # now = Time.now.in_time_zone("Paris")
        # if now.hour < 20 && now.hour > 8 && (now.wday != 6 && now.wday != 0) # On envoi pas si on est pas en soirée ou si on est en WE
        #   sms.send_sms_to_broker(self, self.broker)
        # end
      end
    else
      puts "Subscriber onboardé, mais on le l'a pas mis sur le Trello car on est en dev"
    end
  end

  # Matching methods

  def is_matching_property_price(price)
    (price <= self.max_price ? true : false) if !self.max_price.nil?
  end

  def is_matching_property_surface(surface)
    (surface >= self.min_surface ? true : false) if !self.min_surface.nil?
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

  def is_matching_property_area(area_id, sub_areas = self.areas.ids)
    sub_areas.include?(area_id) ? true : false
  end

  def notify_broker_if_max_price_is_changed
    if !previous_changes["max_price"].nil? && !self.broker.nil? && !self.trello_id_card.nil?
      old_price = previous_changes["max_price"][0]
      new_price = previous_changes["max_price"][1]
      self.notify_broker_trello("Prix d'achat max modifié. Changé de #{old_price} € à #{new_price} €")
    end
  end

  def attribute_adequate_broker
    if self.broker.nil? 
      # 19/05 TEST si il est dans un growth hack, alors on test le BM abonnement 
      if !SubscriberSequence.where(subscriber: self, sequence: Sequence.find_by(name: "HACK - test abonnement payant")).empty?
        shift_type = "subscription"
      else #Sinon on attribue un courtier 'normalement' 
        shift_type = "regular"
      end
      self.update(broker: Broker.get_current(shift_type))
    end
  end
end
