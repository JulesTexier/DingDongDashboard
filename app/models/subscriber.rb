require "dotenv/load"

class Subscriber < ApplicationRecord

  after_create :handle_onboarding
  after_update :notify_broker_if_max_price_is_changed

  # validates_uniqueness_of :facebook_id, :case_sensitive => false
  # validates :facebook_id, presence: true 
  # validates :email, presence: false, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "email is not valid" }
  # validates :phone
  validates :firstname, presence: true
  validates :lastname, presence: true

  belongs_to :broker, optional: true

  has_many :selected_areas
  has_many :areas, through: :selected_areas

  has_many :selected_districts
  has_many :districts, through: :selected_districts

  has_many :favorites
  has_many :fav_properties, through: :favorites, source: :property

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

  def is_matching_property?(property)
    test_price = is_matching_property_price(property)
    test_surface = is_matching_property_surface(property)
    test_rooms_number = is_matching_property_rooms_number(property)
    test_floor = is_matching_property_floor(property)
    test_elevator = is_matching_property_elevator_floor(property)
    test_areas = is_matching_property_area(property)

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
    props = Property.order(id: :desc)
    props_to_send = []

    props.each do |prop|
      self.is_matching_property?(prop) ? props_to_send.push(prop) : nil

      props_to_send.length == max_number.to_i ? break : nil
    end
    return props_to_send
  end

  def get_props_in_lasts_x_days(x_previous_days)
    t = Time.now
    t.in_time_zone("Europe/Paris")
    start_date = t - x_previous_days.to_i.days

    puts start_date

    props = Property.where("created_at >= ?", start_date)

    props_to_send = []

    props.each do |prop|
      self.is_matching_property?(prop) ? props_to_send.push(prop) : nil
    end

    return props_to_send
  end

  def get_morning_props
    # t = Time.now
    # t.in_time_zone("Europe/Paris")
    # byebug
    now = DateTime.now.in_time_zone("Europe/Paris")
    start_date = DateTime.new(now.year, now.month, now.day, 22, 0, 0, now.zone) - 1
    end_date = DateTime.new(now.year, now.month, now.day, 9, 0, 0, now.zone)

    props = Property.where("created_at BETWEEN ? AND ?", start_date, end_date)

    props_to_send = []

    props.each do |prop|
      self.is_matching_property?(prop) ? props_to_send.push(prop) : nil

      props_to_send.length == 10 ? break : nil
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
    desc += "\u000A**Budget Maximum** : #{self.max_price.to_s.reverse.gsub(/...(?=.)/,'\& ').reverse} €"
    desc += "\u000A**Surface Minimum ** : #{self.min_surface} m2"
    desc += "\u000A**Nombre de pièces minimum ** : #{self.min_rooms_number}"
    desc += "\u000A**Arrondissements** : #{self.get_initial_areas}"
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
    byebug
    return areas
  end

  def get_initial_areas
    areas_name = []
    self.initial_areas.split(",").each do |area|
      areas_name.push(Area.find(area).name)
    end
    return areas_name.join(", ")
  end

  private

  # Onboarding methods 
  def handle_onboarding
    byebug
    #0 • Handle duplicate
    if Subscriber.where(email: self.email).size > 1
      handle_duplicate
    # 1 • Handle case user is a real estate hunter 
    elsif self.project_type.downcase.include?("chasseur")
      onboarding_hunter
    # 2 • Handle case user has not Messenger 
    elsif !self.has_messenger 
      onboarding_no_messenger
    else 
      onboarding_broker
    end
  end

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
    self.update(broker: Broker.get_current_broker) if self.broker.nil?
      trello = Trello.new
      sms = SmsMode.new
      if Rails.env.production?
        if trello.add_new_user_on_trello(self)
          self.broker.send_email_notification(self) 
          sms.send_sms_to_broker(self, self.broker)
        end
      else
        puts "Subscriber créé, mais on le l'a pas mis sur le Trello car on est en dev"
    end
  end

  # Matching methods 

  def is_matching_property_price(property)
    (property.price <= self.max_price ? true : false) if !self.max_price.nil?
  end

  def is_matching_property_surface(property)
    (property.surface >= self.min_surface ? true : false) if !self.min_surface.nil?
  end

  def is_matching_property_rooms_number(property)
    (property.rooms_number.to_i >= self.min_rooms_number ? true : false) if !self.min_rooms_number.nil?
  end

  def is_matching_property_floor(property)
    if self.min_floor.nil?
      return true
    else
      if !property.floor.nil?
        (property.floor.to_i >= self.min_floor ? true : false) if !self.min_floor.nil?
      else
        return true
      end
    end
  end

  def is_matching_property_elevator_floor(property)
    if self.min_elevator_floor.nil?
      return true
    else
      if !property.has_elevator.nil?
        if property.has_elevator
          return true
        else
          property.floor.to_i < self.min_elevator_floor.to_i ? true : false
        end
      else
        return true
      end
    end
  end

  def is_matching_property_area(property)
    self.areas.include?(property.area) ? true : false
  end

  def notify_broker_if_max_price_is_changed
    if !previous_changes["max_price"].nil? && !self.broker.nil? && !self.trello_id_card.nil?
      old_price = previous_changes["max_price"][0]
      new_price = previous_changes["max_price"][1]
      self.notify_broker_trello("Prix d'achat max modifié. Changé de #{old_price} € à #{new_price} €")
    end
  end
end
