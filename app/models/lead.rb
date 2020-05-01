class Lead < ApplicationRecord
  belongs_to :broker, optional: true
  after_create :handle_onboarding


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
    desc += "\u000A**Arrondissements** : #{self.areas}"
    desc += "\u000A**Critère(s) spécifique(s)** : #{self.specific_criteria}" if !self.specific_criteria.nil?
    desc += "\u000A**Question(s) additionelle(s)** : #{self.additional_question}" if !self.additional_question.nil?
    desc += "\u000A\u000A**#{self.get_fullname} a déclaré ne pas avoir Messenger**" if !self.has_messenger
    desc += "\u000A\u000A*Inscription chez DingDong : #{self.created_at.in_time_zone("Paris").strftime("%d/%m/%Y - %H:%M")}*"
  end

  def get_chatbot_link
    return "https://m.me/HiDingDong?ref=welcome--#{self.id}"
  end

  def get_fullname
    return self.firstname + " " + self.lastname
  end

  
  private 
  
  def handle_onboarding
    # 0 • Handle case lead is duplicated
    if !Lead.where(email: self.email).empty?
      handle_duplicate
    # 1 • Handle case lead is a real estate hunter 
    elsif self.project_type.downcase.include?("chasseur")
      onboarding_hunter
    # 2 • Handle case lead has not Messenger 
    elsif !self.has_messenger 
      add_lead_on_trello_no_messenger
    else 
      onboarding_broker
    end
  end

  def handle_duplicate
    self.update(status: "duplicates")
    PostmarkMailer.send_lead_dulicate_email(self).deliver_now if !self.email.nil?
  end
  
  def onboarding_hunter
    # Send email to lead with Max in C/C
    PostmarkMailer.send_onboarding_hunter_email(self).deliver_now if !self.email.nil?
  end

  def add_lead_on_trello_no_messenger
    # Send email to lead with explainations 
    PostmarkMailer.send_email_to_lead_with_no_messenger(self).deliver_now
  end


  def onboarding_broker
    self.update(broker: Broker.get_current_broker) if self.broker.nil?
      trello = Trello.new
      sms = SmsMode.new
      if trello.add_new_lead_on_trello(self)
        self.broker.send_email_notification(self) if Rails.env.production?
        sms.send_sms_to_broker(self, self.broker) if Rails.env.production?
      end
  end
  
end
