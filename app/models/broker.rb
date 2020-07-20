require "dotenv/load"

class Broker < ApplicationRecord

  has_many :leads
  has_many :subscribers

  has_many :permanences
  has_many :shifts, through: :permanences, source: :broker_shift

  def get_board_url
    return "https://trello.com/b/" + self.trello_board_id
  end

  def send_email_notification(user)
    PostmarkMailer.send_new_lead_notification_to_broker(user).deliver_now if !self.email.nil?
  end

  def self.get_broker_by_username(username)
    return self.where(trello_username:username).first
  end

  def self.send_good_morning_message_leads
    now = DateTime.now.in_time_zone("Europe/Paris")
    time_limit = DateTime.new(now.year, now.month, now.day, 20, 0, 0, now.zone) - 1
    sms = SmsMode.new
    self.all.each do |broker|
      nb_lead = broker.subscribers.where("status = 'form_filled' AND created_at > ? ", time_limit).size
      sms.send_good_morning_sms_to_broker(broker, nb_lead) if nb_lead > 0
    end
  end

  def self.get_currents(shift_type = "regular")
    shift = BrokerShift.get_current(shift_type)
    shift.nil? ? [] : brokers = shift.brokers
  end

  def self.get_current(shift_type = "regular")
    brokers = Broker.get_currents(shift_type)
    !brokers.empty? ? brokers[rand(0..brokers.length-1)] : nil
  end

  def self.get_current_lead_gen
    candice = Broker.find_by(email: "ca.timmerman@meilleurtaux.com")
    erika = Broker.find_by(email: "e.meteau@meilleurtaux.com")
    benoit = Broker.find_by(email: "b.leroux@meilleurtaux.com")
    benoit = Broker.find_by(email: "a.meneghino@meilleurtaux.com")

    morning_end = 13
    afternooon_end = 20
    date = Time.now.in_time_zone("Paris")
    b = nil
    case date.wday
    when 0
      b = [candice, adrien].sample
    when 1 
      if date.hour < afternooon_end
        b = [candice, adrien].sample
      else 
        b = [candice, adrien, benoit, erika].sample
      end
    when 2 || 3 || 4
        b = [candice, adrien, benoit, erika].sample
    when 5 
      if  date.hour < afternooon_end
        b = [candice, adrien, benoit, erika].sample
      else 
        b = [benoit, erika].sample
      end
    when 6 
      if date.hour < afternooon_end
        b = [benoit, erika].sample
      else 
        b = [candice, adrien].sample
      end
    else
      b = [candice, adrien].sample
    end
    return b
  end

  # def self.get_current_broker(date = Time.now)

  #   if !ENV['BROKER'].nil? && !Rails.env.test?
  #     b = self.where(trello_username:ENV['BROKER']).first
  #   else
      

  #     # lundi matin : hugo
  #     # lundi aprem : véronique
  #     # mardi matin : greg
  #     # mardi aprem : mélanie
  #     # mercredi matin : hugo
  #     # mercredi aprem : amélie
  #     # jeudi matin : mélanie
  #     # jeudi aprem : greg
  #     # vendredi matin : amélie
  #     # vendredi aprem : véronique

  #     aurelien = "aurelienguichard1"
  #     melanie = "melanieramon2"
  #     hugo = "cohen172"
  #     amelie = "kleinamelie"
  #     veronique = "veroniquebenazet"
  #     greg = "gregrouxeloldra"

  #     morning_end = 13
  #     afternooon_end = 20
  #     date = date.in_time_zone("Paris")
  #     case date.wday
  #     when 0
  #       b = self.get_broker_by_username(greg)
  #     when 6
  #       b = self.get_broker_by_username(greg)
  #     when 1 #Lundi  : Aprem : Véronique
  #       if date.hour < morning_end
  #         b = self.get_broker_by_username(greg)
  #       elsif date.hour >= morning_end && date.hour < afternooon_end
  #         b = self.get_broker_by_username(greg)
  #       else 
  #         b = self.get_broker_by_username(greg)
  #       end
  #     when 2 #Mardi  : Matin Aurélien, Aprem : Mélanie
  #       if date.hour < morning_end
  #         b = self.get_broker_by_username(greg)
  #       elsif date.hour >= morning_end && date.hour < afternooon_end
  #         b = self.get_broker_by_username(melanie)
  #       else 
  #         b = self.get_broker_by_username(hugo)
  #       end
  #     when 3 #Mercredi  : Aprem : Véronique
  #       if date.hour < morning_end
  #         b = self.get_broker_by_username(hugo)
  #       elsif date.hour >= morning_end && date.hour < afternooon_end
  #         b = self.get_broker_by_username(amelie)
  #       else 
  #         b = self.get_broker_by_username(melanie)
  #       end
  #     when 4  #Jeudi  : Matin Mélanie, Aprem : Aurélien
  #       if date.hour < morning_end
  #         b = self.get_broker_by_username(melanie)
  #       elsif date.hour >= morning_end && date.hour < afternooon_end
  #         b = self.get_broker_by_username(greg)
  #       else 
  #         b = self.get_broker_by_username(amelie)
  #       end
  #     when 5 #Vendredi  : Matin Mélanie, Aprem : Aurélien
  #       if date.hour < morning_end
  #         b = self.get_broker_by_username(amelie)
  #       elsif date.hour >= morning_end && date.hour < afternooon_end
  #         b = self.get_broker_by_username(hugo)
  #       else 
  #         b = self.get_broker_by_username(greg)
  #       end
  #     else
  #       b = self.get_broker_by_username("gregrouxeloldra")
  #     end
  #   end
  #   return b

  # end

  # def self.get_current_broker_subscription_bm(date = Time.now)

  #   if !ENV['BROKER'].nil? && !Rails.env.test?
  #     b = self.where(trello_username:ENV['BROKER']).first
  #   else

  #     # aurelien = "aurelienguichard1"
  #     etienne = "etienne_dingdong"
  #     b = self.find_by(trello_username: etienne)

  #     # morning_end = 13
  #     # afternooon_end = 20
  #     # date = date.in_time_zone("Paris")
  #     # case date.wday
  #     # when 1 #Lundi  : Soirée : Aurélien
  #     #   if date.hour >= afternooon_end
  #     #     b = self.get_broker_by_username(aurelien)
  #     #   end
  #     # when 2 #Mardi  : Matin Aurélien
  #     #   if date.hour < morning_end
  #     #     b = self.get_broker_by_username(aurelien)
  #     #   end
  #     # when 4  #Jeudi  : Aprem : Aurélien
  #     #   if date.hour >= morning_end && date.hour < afternooon_end
  #     #     b = self.get_broker_by_username(aurelien)
  #     #   end
  #     # else
  #     #   b = self.find_by(trello_username: "gregrouxeloldra")
  #     # end
  #   end
  #   return b

  # end
  
  def get_users_by_column
    trello = Trello.new
    results = []
    status = ["En attente", "Intéressé", "Peu intéressé", "Pas intéressé", "Jamais de réponse", "Plus en recherche", "Plus de nouvelle", "En étude (rdv courtier simulation, documents, lettre de confort etc.)", "Offre acceptée (mandat + pièces)", "Instruction"]
    lists = trello.get_broker_lists(self)
    lists.each do |item|
      if status.include?(item["name"])
        self.trello_board_id.nil? ? cards = 0 : cards = trello.get_cards_on_list(item["id"])
        results.push({category: item["name"], count: cards.count })
      end
    end
    return results
  end

end
