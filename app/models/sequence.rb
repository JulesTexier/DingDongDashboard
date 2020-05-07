class Sequence < ApplicationRecord
  has_many :subscriber_sequences
  has_many :subscribers, through: :subscriber_sequences

  has_many :sequence_steps

  def self.get_adequate_sequence(marketing_type, source, sender_email, sequence_type)
    self.where(marketing_type: marketing_type, source: source, sender_email: sender_email, sequence_type: sequence_type, is_active: true).last
  end

  def execute_sequence(subscriber)
    self.sequence_steps.each do |step|
      step.execute_step(subscriber)
    end
    puts "JE SUIS DANS LEXECUTE"
  end
end
