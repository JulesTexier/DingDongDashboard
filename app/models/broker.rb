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
    self.subscribers.where(hot_lead: true).where('created_at >= ?', Time.now - BROKER_LEADS_OFFSET.day).order('created_at DESC') + self.subscribers.includes(:subscriber_notes, research: [:areas]).where('created_at <  ?', Time.now - BROKER_LEADS_OFFSET.day).order('created_at DESC') 
  end

  # This method is perfomred every morning at 9 by scheduler 
  def self.notify_daily_leads
    BrokerAgency.selectable_agencies.each do |broker_agency|
      broker_agency.brokers.each do |broker|
        new_leads_count = broker.subscribers.where(broker_status: "Non traité").where('created_at > ?', Time.now - 8.days).where('created_at < ?', Time.now - 7.days).count
        hot_leads_to_call = broker.subscribers.where('broker_meeting > ? AND broker_meeting < ?', Date.today.beginning_of_day, Date.today.end_of_day).map{|s| s.id}
        if new_leads_count > 0 || hot_leads_to_call.count > 0
          BrokerMailer.send_morning_new_leads_notification(broker.id, new_leads_count, hot_leads_to_call).deliver_now
        end
      end
    end
  end

  def self.get_accurate_by_agglomeration(agglomeration_id)
      # Select BA from agglomeration 
      broker_agency_scope = BrokerAgency.selectable_agencies.where(agglomeration_id: agglomeration_id)
      unless broker_agency_scope.empty? 

        # Calculate each BA progress in current period 
        broker_agency_progress = broker_agency_scope.map{ |ba| [ba.id, ba.progress]}
        
        # Sort by progress (min to max)
        sorted_broker_agency_progress = broker_agency_progress.sort { |x,y| x[1] <=> y[1] }

        # Ensure to select an agency with brokers 
        selected_agency = BrokerAgency.find(sorted_broker_agency_progress[0][0])
        unless selected_agency.nil? || selected_agency.brokers.empty?
        # Get broker from BA with the fewer nb of leads since start of the month
          broker_hash = {}
          selected_agency.brokers.each{ |b| broker_hash[b.id] = b.subscribers.where('created_at > ?', Date.today.at_beginning_of_month).count }
          # Uodate agency counters
          selected_agency.update(current_period_leads_left: selected_agency.current_period_leads_left - 1, current_period_provided_leads: selected_agency.current_period_provided_leads + 1)
          return Broker.find(broker_hash.sort_by{|id, leads| leads}.first[0])
        else
          puts "Error, there is no available Broker for any Broker Agency in agglomeration_id #{agglomeration_id}"
          Broker.return_default_broker
        end
      else
        puts "Error, there is no available Broker Agency for agglomeration_id #{agglomeration_id}"
        Broker.return_default_broker
      end
  end

  def self.return_default_broker
    ba = BrokerAgency.find_by(name: "Ding Dong Courtage")
    ba.nil? ? nil : default_ba = Broker.where(broker_agency: ba).first
  end


end
