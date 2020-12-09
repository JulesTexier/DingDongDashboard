class BrokerAgency < ApplicationRecord
  has_many :brokers 
  belongs_to :agglomeration

  def get_subscribers(from = Time.parse("01/01/2000"), to = Time.now)
    self.brokers.map{|b| b.subscribers.where("created_at > ? AND created_at < ?", from, to+1.day)}.flatten
  end

  def self.selectable_agencies
    BrokerAgency.where('current_period_leads_left > ? ', 0).where(status: ["test", "premium"])
  end
end
