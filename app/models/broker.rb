require "dotenv/load"

class Broker < ApplicationRecord

  has_many :subscribers

  has_many :permanences # a voir
  has_many :shifts, through: :permanences, source: :broker_shift #a voir


  # A REFACTO
  def send_email_notification(user)
    PostmarkMailer.send_new_lead_notification_to_broker(user).deliver_now if !self.email.nil?
  end

  # REFACTO : A VOIR SI ON GARDE ... 
  def self.send_good_morning_message_leads
    now = DateTime.now.in_time_zone("Europe/Paris")
    time_limit = DateTime.new(now.year, now.month, now.day, 20, 0, 0, now.zone) - 1
    sms = SmsMode.new
    self.all.each do |broker|
      nb_lead = broker.subscribers.where("status = 'form_filled' AND created_at > ? ", time_limit).size
      sms.send_good_morning_sms_to_broker(broker, nb_lead) if nb_lead > 0
    end
  end

  # REFACTO : A SUPPRIMER 
  def self.get_currents(shift_type = "regular")
    shift = BrokerShift.get_current(shift_type)
    shift.nil? ? [] : brokers = shift.brokers
  end

  # REFACTO : A SUPPRIMER 
  def self.get_current(shift_type = "regular")
    brokers = Broker.get_currents(shift_type)
    !brokers.empty? ? brokers[rand(0..brokers.length-1)] : nil
  end

  # REFACTO : A DEV POUR MATCHER AU NEW BM
  def self.get_current_lead_gen
    if Rails.env == "development"
      return Broker.find_by(email: "etienne@hellodingdong.com")
    end
    candice = Broker.find_by(email: "ca.timmerman@meilleurtaux.com")
    erika = Broker.find_by(email: "e.meteau@meilleurtaux.com")
    benoit = Broker.find_by(email: "b.leroux@meilleurtaux.com")
    adrien = Broker.find_by(email: "a.meneghini@meilleurtaux.com")

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

end
