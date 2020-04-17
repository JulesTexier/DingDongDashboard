class Broker < ApplicationRecord

  has_many :leads
  has_many :subscribers

  def self.get_broker_by_username(username)
    return self.where(trello_username:username).first
  end

  def self.get_current_broker(date = Time.now)
    b = self.where(trello_username:"gregrouxeloldra").first

#     Lundi matin : hugo
# lundi aprem : véronique
# mardi matin : aurélien
# mardi aprem : mélanie
# mercredi matin : hugo
# mercredi aprem : amélie
# jeudi matin : mélanie
# jeudi aprem : aurélien
# vendredi matin : amélie
# vendredi aprem : véronique

    aurelien = "aurelienguichard1"
    melanie = "melanieramon2"
    hugo = "cohen172"
    amelie = "kleinamelie"
    veronique = "veroniquebenazet"

    morning_end = 13
    afternooon_end = 18
    date = date.in_time_zone("Paris")

    case date.wday
    when 1 #Lundi  : Aprem : Véronique
      if date.hour < morning_end
        b = get_broker_by_username(hugo)
      elsif date.hour >= morning_end && date.hour < afternooon_end
        b = get_broker_by_username(veronique)
      else 
        b = get_broker_by_username(aurelien)
      end
    when 2 #Mardi  : Matin Aurélien, Aprem : Mélanie
      if date.hour < morning_end
        b = get_broker_by_username(aurelien)
      elsif date.hour >= morning_end && date.hour < afternooon_end
        b = get_broker_by_username(melanie)
      else 
        b = get_broker_by_username(hugo)
      end
    when 3 #Mercredi  : Aprem : Véronique
      if date.hour < morning_end
        b = get_broker_by_username(hugo)
      elsif date.hour >= morning_end && date.hour < afternooon_end
        b = get_broker_by_username(amelie)
      else 
        b = get_broker_by_username(melanie)
      end
    when 4  #Jeudi  : Matin Mélanie, Aprem : Aurélien
      if date.hour < morning_end
        b = get_broker_by_username(melanie)
      elsif date.hour >= morning_end && date.hour < afternooon_end
        b = get_broker_by_username(aurelien)
      else 
        b = get_broker_by_username(amelie)
      end
    when 5 #Vendredi  : Matin Mélanie, Aprem : Aurélien
      if date.hour < morning_end
        b = get_broker_by_username(amelie)
      elsif date.hour >= morning_end && date.hour < afternooon_end
        b = get_broker_by_username(veronique)
      else 
        b = get_broker_by_username(hugo)
      end
    else
      b = get_broker_by_username("gregrouxeloldra")
    end
    
    return b

  end

end
