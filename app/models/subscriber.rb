require "dotenv/load"

class Subscriber < ApplicationRecord

  after_create :send_confirmation_email
  after_create :professional_attribution

  ## REVOIR LES VALIDATEURS

  has_many :selected_areas
  has_many :areas, through: :selected_areas

  has_one :research

  has_many :subscriber_sequences
  has_many :sequences, through: :subscriber_sequences

  has_many :subscriber_statuses
  has_many :statuses, through: :subscriber_statuses

  ## A SUPPRIMER APRES LE SEED
  has_many :favorites
  has_many :fav_properties, through: :favorites, source: :property

  ## Professional association
  belongs_to :notary, optional: true
  belongs_to :contractor, optional: true
  belongs_to :broker, optional: true


  ########################
  # 1 - Business methods
  ########################

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

  def determine_zone
    subscriber_zone = []
    self.areas.pluck(:zone).uniq.each do |zone|
      subscriber_zone.push(Area.get_agglo_from_zone(zone))
    end
    subscriber_zone.flatten.uniq
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


  ############################
  # Professional Attribution #
  ############################

  def professional_attribution
    self.notary = Notary.first if self.notary.nil?
    self.contractor = Contractor.first if self.contractor.nil?
    self.broker = Broker.find_by(email: 'etienne@hellodingdong.com') if self.broker.nil?
    self.save
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

  def self.active_with_research
    self.includes(:research).where(is_active: true, is_blocked: [nil, false]).where.not(researches: { id: nil })
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
  
  def validate_email
    self.email_confirmed = true
    self.confirm_token = nil
  end

  private

  ###########################
  # Email confirmation methods
  ###########################


  def set_confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end

  def send_confirmation_email
    if self.email_flux
      set_confirmation_token
      self.save(validate: false)
      SubscriberMailer.registration_confirmation(self).deliver_now
    end
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


