require "dotenv/load"

class Broker < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  has_one_attached :avatar

  has_many :subscribers

  has_many :permanences # a voir
  has_many :shifts, through: :permanences, source: :broker_shift #a voir

  belongs_to :agglomeration, optional: true
  belongs_to :broker_agency, optional: true

  def get_fullname
    return "#{self.firstname} #{self.lastname}"
  end

  # This method is perfomred every morning at 9 by scheduler 
  def self.notify_daily_leads
    BrokerAgency.selectable_agencies.each do |broker_agency|
      broker_agency.brokers.each do |broker|
        new_leads_count = broker.subscribers.where(broker_status: "Non traité").where('created_at > ?', Time.now - 8.days).where('created_at < ?', Time.now - 7.days).count
        if new_leads_count > 0
          BrokerMailer.send_morning_new_leads_notification(broker.id, new_leads_count).deliver_now
        end
      end
    end
  end

  # A REFACTO
  # def send_email_notification(user)
  #   PostmarkMailer.send_new_lead_notification_to_broker(user).deliver_now if !self.email.nil?
  # end

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

  def get_subscribers_data_weekly_update
    subs = self.subscribers.where.not(research_id: nil).pluck(:id, :firstname, :lastname, :created_at, :is_active, :email, :phone, :research_id)
    subs.each do |sub|
      sub.push("#{sub[1]}  #{sub[2]}")
      saved_properties = SavedProperty.where(research_id_id: sub[7])
      sub.push(saved_properties.count)
      sub.push(saved_properties.where('created_at > ? ', Time.now - 7.days).count)
    end
  end

  # November 2020 : Up to date with business logic 
  def self.get_accurate_by_agglomeration(agglomeration_id)

    # Select BA from agglomeration 
    broker_agency_scope = BrokerAgency.selectable_agencies.where(agglomeration_id: agglomeration_id)

    # Calculate each BA progress in current period 
    broker_agency_progress = broker_agency_scope.map{ |ba| [ba.id, (ba.current_period_provided_leads/ba.current_period_leads_left.to_f)]}
    
    # Sort by progress (min to max)
    sorted_broker_agency_progress = broker_agency_progress.sort { |x,y| x[1] <=> y[1] }

    # Ensure to select an agency with brokers 
    selected_agency = BrokerAgency.find(sorted_broker_agency_progress[0][0])
      i = 0
      while BrokerAgency.find(sorted_broker_agency_progress[i][0]).brokers.count == 0 
        selected_agency = BrokerAgency.find(sorted_broker_agency_progress[i+1][0])
        i += 1
      end
    # Get broker from BA with le fewer nb of leads since start of the month
    broker_hash = {}
    selected_agency.brokers.each{ |b| broker_hash[b.id] = b.subscribers.where('created_at > ?', Date.today.at_beginning_of_month).count }
    # Uodate agency counters
    selected_agency.update(current_period_leads_left: selected_agency.current_period_leads_left - 1, current_period_provided_leads: selected_agency.current_period_provided_leads + 1)
    return Broker.find(broker_hash.sort.first[0])
  end

end
