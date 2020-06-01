class Sequence < ApplicationRecord
  has_many :subscriber_sequences
  has_many :subscribers, through: :subscriber_sequences

  has_many :sequence_steps

  validates :name, presence: true
  validates :sender_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :marketing_type, presence: true

  def self.get_adequate_sequence(marketing_type, source, sender_email, sequence_type)
    self.where(marketing_type: marketing_type, source: source, sender_email: sender_email, sequence_type: sequence_type, is_active: true).last
  end

  def get_sequence_infos
    sequence_step_number = self.sequence_steps.count.to_s
    sequence_step_objects = self.sequence_steps
    puts "\n\n*** SEQUENCE INFOS ***"
    puts "\nSequence ID : #{self.id}"
    puts "Sequence Name : #{self.name}"
    puts "Sequence Marketing Type : #{self.marketing_type}"
    puts "Sequence Source: #{self.source}"
    puts "Sequence Sender Email : #{self.sender_email}"
    puts "Sequence active? #{self.is_active}"
    puts "Steps Number : #{sequence_step_number}\n"
    sequence_step_objects.each do |step|
      step.get_step_infos
    end
    puts "*** END OF SEQUENCE INFOS ***\n\n"
  end

  def execute_sequence(subscriber, property_data = nil)
    self.sequence_steps.each do |step|
      step.execute_step(subscriber, property_data)
    end
  end
end
