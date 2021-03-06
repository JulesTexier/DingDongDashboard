class SequenceStep < ApplicationRecord
  belongs_to :sequence

  after_create :create_adequate_status

  validates :step, presence: true, numericality: { only_integer: true }
  validates :step_type, presence: true
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

  def execute_step(subscriber, property_data)
    if Rails.env.production?
      GrowthEngineJob.set(wait: self.respectable_sending_hours(8, 23).hour).perform_later(self.id, subscriber.id, property_data)
    else
      GrowthEngineJob.set(wait: 5.second).perform_later(self.id, subscriber.id, property_data)
    end
  end

  def respectable_sending_hours(start_day, end_day)
    a = DateTime.now + self.time_frame.hour
    if a.hour < start_day
      self.time_frame + (start_day - a.hour)
    elsif a.hour > end_day
      time_frame_adjustment = (a.hour - end_day) + start_day
    else
      self.time_frame
    end
  end

  def get_status_name
    "sequence_" + self.sequence.id.to_s + "_step_" + self.id.to_s
  end

  private

  def create_adequate_status
    Status.create(name: get_status_name, description: self.description, status_type: "acquisition")
  end
end
