require "dotenv/load"

class Subscriber < ApplicationRecord

  after_create :send_confirmation_email

  ## REVOIR LES VALIDATEURS
  
  has_one :research

  has_many :subscriber_sequences
  has_many :sequences, through: :subscriber_sequences

  has_many :subscriber_statuses
  has_many :statuses, through: :subscriber_statuses
  
  has_many :subscriber_notes

  ## Professional association
  belongs_to :notary, optional: true
  belongs_to :contractor, optional: true
  belongs_to :broker, optional: true

  validates :phone, format: { with: /\A(0|\+[1-9]{2})[1-7]{1}[0-9]{8}\z/, message: "Format non valide du numéro de téléphone"}, on: [:onboarding, :growth_onboarding]
  validates :facebook_id, uniqueness: true, on: :facebook_creation
  validates_uniqueness_of :phone, message: "Ce numéro est déjà enregistré dans notre base", on: [:onboarding, :growth_onboarding]
  validates_uniqueness_of :email, message: "Cette adresse email est déjà enregistrée dans notre base", on: :onboarding

  ########################
  # 1 - Business methods
  ########################

   def has_interacted(last_interaction, day_range)
    response = false
    parsed_last_interaction = Time.parse(last_interaction)
    if Time.now < parsed_last_interaction + day_range.days
      response = true
    end
    return response
  end

  # A voir ... (util pour Etienne ?)
  def notify_broker_trello(comment)
    # Trello.new.add_comment_to_user_card(self, comment)
  end

  def handle_onboarding
    professional_attribution
    add_subscriber_to_etienne_trello
  end

  

  ##########################
  ## Nurturing Mailer Job ##
  ##########################
  
  ## Task executed in subscriber method validate_email 
  def execute_nurturing_mailer
    if self.email_flux && self.email_confirmed
      nurturing_mailers = NurturingMailer.where(is_active: true)
      nurturing_mailers.each do |nurturing_mailer|
        NurturingMailerJob.set(wait: nurturing_mailer.time_frame.hour).perform_later(self, nurturing_mailer)
      end
    end
  end


  ########################
  # 2 - Core methods
  ########################

  # TRELLO METHODS
  
  def trello_summary
    desc = "**#{self.get_fullname.upcase}**"
    desc += "\u000A **Tél:** #{self.phone} \u000A **Email:** #{self.email}\u000A"
    desc += "\u000A**Medium** : #{self.get_medium}"
    desc += "\u000A\u000A*Inscription chez DingDong : #{Time.now.in_time_zone("Paris").strftime("%d/%m/%Y - %H:%M")}*"
    desc += "\u000A\u000A---\u000A\u000A"
    desc += "\u000A**RECHERCHE**\u000A"
    desc += "\u000A**Budget Maximum** : #{self.research.max_price.to_s.reverse.gsub(/...(?=.)/, '\& ').reverse} €"
    desc += "\u000A**Budget Minimum ** : #{self.research.min_price} €"
    desc += "\u000A**Surface Minimum ** : #{self.research.min_surface} m2"
    desc += "\u000A**Nombre de pièces minimum ** : #{self.research.min_rooms_number}"
    desc += "\u000A**Areas** : #{self.get_areas_list}"
    desc += "\u000A\u000A---\u000A\u000A"
    desc += "\u000A**PROS**\u000A"
    desc += "\u000A\u000A**Courtier :** #{self.broker.firstname} #{self.broker.lastname}" unless self.broker.nil?
    desc += "\u000A\u000A**Entrepreneur :** #{self.contractor.firstname} #{self.contractor.lastname}" unless self.contractor.nil?
    desc += "\u000A\u000A**Notaire :** #{self.notary.firstname} #{self.notary.lastname}" unless self.notary.nil?
  end

  def get_fullname
    return "#{self.firstname} #{self.lastname}"
  end

  def get_areas_list
    areas = ""
    unless self.research.nil?
      self.research.areas.each do |area|
        areas += area.name + ", "
      end
    end
    return areas
  end

  def get_medium 
    if self.messenger_flux
      "Messenger"
    else 
      "Alerte email"
    end
  end

  def get_areas
    areas = []
    self.areas.each do |area|
      areas.push(area.name)
    end
    return areas
  end

  def get_edit_path
    return ENV["BASE_URL"] + "subscribers/" + self.id.to_s + "/research/edit"
  end

  def get_criteria
    desc =  ""
    desc += "\u000ABudget max: #{self.research.max_price.to_s.reverse.gsub(/...(?=.)/, '\& ').reverse} € |"
    desc += "\u000ASurface min: #{self.research.min_surface} m2 | " 
    desc += "\u000ANb pces min: #{self.research.min_rooms_number} | "
    desc += "\u000AZone de recherche: #{self.get_areas_list}"
    return desc
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
    self.is_active = true
    self.execute_nurturing_mailer
  end

  private

  ############################
  # Professional Attribution #
  ############################


  def professional_attribution
    self.notary = Notary.first if self.notary.nil?
    self.contractor = Contractor.first if self.contractor.nil?
    self.broker = get_accurate_broker if self.broker.nil?
    self.save
  end

  def get_accurate_broker
    Broker.get_accurate_by_agglomeration(self.research.agglomeration.id)
  end

  ############################
  # Etienne Trello follow up 
  ############################

  def add_subscriber_to_etienne_trello
    Trello.new.add_lead_on_etienne_trello(self)
  end


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


