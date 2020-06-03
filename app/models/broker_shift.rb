class BrokerShift < ApplicationRecord
  has_many :permanences
  has_many :brokers, through: :permanences

  def self.get_current(shift_type = "regular")
    current_shift = nil
    time = Time.now.in_time_zone('Paris') 
    day = time.wday
    hour = time.hour
    shifts_of_the_day = BrokerShift.where(shift_type: shift_type, day: day)
    shifts_of_the_day.each do |shift|
      if hour >= shift.starting_hour && hour <= shift.ending_hour
        current_shift =  shift
        break
      end
    end

    # Case we are in an 'active' shift 
    if !current_shift.nil?
      return current_shift
    # Case we are not 
    else 
      if (time.wday == 6 || time.wday == 0) || (time.hour > 18 && time.wday == 5)
        return BrokerShift.where(shift_type: shift_type, day: 1).order(:starting_hour).first
      elsif time.hour > 18
        tomorrow = DateTime.now.tomorrow.to_date
        return BrokerShift.where(shift_type: shift_type, day: tomorrow.wday).order(:starting_hour).first
      elsif time.hour >= 0 && time.hour < 9
        return BrokerShift.where(shift_type: shift_type, day: time.wday).order(:starting_hour).first
      end
    end
  end

  private

  def get_next_shift(time = Time.now)
    now = time.in_time_zone('Paris') 
    tomorrow = DateTime.now.tomorrow.to_date
    if now.hour > 18 
      return BrokerShift.where(day: date.wday).order(:starting_hour).first
    elsif now >= 0 && now < 9
      return BrokerShift.where(day: now.wday).order(:starting_hour).first
    end
  end
end
