class SequenceStep < ApplicationRecord
  belongs_to :sequence

  validates :step, presence: true, numericality: { only_integer: true }
  validates :step_type, presence: true
  validates :template, presence: true
  validates :time_frame, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def get_step_infos
    puts "\n\n*** STEP INFO - NUMBER #{self.step.to_s}"
    puts "Step ID : #{self.id}"
    puts "Step Name : #{self.name}"
    puts "Step Description : #{self.description}"
    puts "Step Type: #{self.step_type}"
    puts "Step Time Frame : #{self.time_frame}"
    puts "Step template #{self.template}"
    puts "*** END OF STEP INFO **\n\n"
  end

  def execute_step(subscriber)
    case self.sequence.sequence_type
    when "Mail"
      if Rails.env.production?
        GrowthMailer.send_growth_email_gmail(self, subscriber).deliver_later(wait: self.respectable_sending_hours(8, 23).hour)
      else
        GrowthMailer.send_growth_email_gmail(self, subscriber).deliver
      end
    else
      puts "error"
    end
  end

  def respectable_sending_hours(start_day, end_day)
    a = DateTime.now + self.time_frame
    if a.hour < start_day
      time_frame_adjustment = start_day - a.hour
      self.time_frame + time_frame_adjustment
    elsif a.hour >= end_day
      time_frame_adjustment = (a.hour - end_day) + start_day
    else
      self.time_frame
    end
  end
end
