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

  BROKER_LEADS_OFFSET = 7

  def get_fullname
    return "#{self.firstname} #{self.lastname}"
  end

  def get_available_leads(offset = BROKER_LEADS_OFFSET)
    self.subscribers.where('created_at <  ?', Time.now - BROKER_LEADS_OFFSET.day).order('created_at DESC')
  end

  ########################
  # 3 - Class methods
  ########################

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
