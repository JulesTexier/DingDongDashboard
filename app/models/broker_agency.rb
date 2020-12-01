class BrokerAgency < ApplicationRecord
  has_many :brokers 
  belongs_to :agglomeration

  def self.selectable_agencies
    BrokerAgency.where('current_period_leads_left > ? ', 0).where(status: ["test", "premium"])
  end
end
