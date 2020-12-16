class BrokerAgency < ApplicationRecord
  has_many :brokers 
  belongs_to :agglomeration

  def get_subscribers(from = Time.parse("01/01/2000"), to = Time.now)
    self.brokers.map{|b| b.subscribers.where("created_at > ? AND created_at < ?", from, to+1.day)}.flatten
  end

  def progress
    (self.current_period_provided_leads.to_f / self.max_period_leads.to_f).round(2)
  end

  def self.selectable_agencies
    BrokerAgency.where('current_period_leads_left > ? ', 0).where(status: ["test", "premium"]).where.not(name: "Ding Dong Courtage")
  end

  def self.create_default
    ba = BrokerAgency.create(name: "Ding Dong Courtage", max_period_leads: 100000, current_period_leads_left: 10000, default_pricing_lead: 0, agglomeration_id: Agglomeration.all.first.id, status: "test")
    Broker.create(broker_agency_id: ba.id, firstname:"Anne", lastname:"Gillet", email:"etienne+99@hellodingdong.com", phone:"‭+33616766149‬", agglomeration_id: Agglomeration.all.first.id, password: "DingDong")
  end
end
