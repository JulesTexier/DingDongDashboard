class Broker < ApplicationRecord

  has_many :leads

  def self.get_current_broker
    return self.first
  #   week_day = Time.now.wday
  end

end
