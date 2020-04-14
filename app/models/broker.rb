class Broker < ApplicationRecord

  has_many :leads
  has_many :subscribers

  def self.get_current_broker
    b = self.where(trello_username:"gregrouxeloldra").first

    morning_end = 13
    afternooon_end = 18
    date = Time.now.in_time_zone("Paris")

    case date.wday
    when 2 #Mardi  : Matin Aurélien, Aprem : Mélanie
      if date.hour < morning_end
        b = self.where(trello_username:"aurelienguichard1").first
      elsif date.hour < afternooon_end
        b = self.where(trello_username:"melanieramon2").first
      end
    when 4 #Jeudi  : Matin Mélanie, Aprem : Aurélien
      if date.hour < morning_end
        b = self.where(trello_username:"melanieramon2").first
      elsif date.hour < afternooon_end
        b = self.where(trello_username:"aurelienguichard1").first
      end
    else
    end
    
    return b

  end

end
