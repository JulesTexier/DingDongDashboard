class Sequence < ApplicationRecord
  has_many :subscriber_sequences
  has_many :subscribers, through: :subscriber_sequences

  has_many :sequence_steps

  def self.get_adequate_sequence(name, source, sender_email)
    self.where(name: name, source: source, sender_email: sender_email, is_active: true).last
  end

  def self.execute(subscriber)
    puts "JE SUIS DANS LEXECUTE"
  end
end
