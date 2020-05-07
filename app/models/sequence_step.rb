class SequenceStep < ApplicationRecord
  belongs_to :sequence

  def initialize
    @postmark = PostmarkMailer.new
  end

  def execute_step(subscriber)
    case self.sequence.sequence_type
    when "Mail"
      byebug
      @postmark.send_growth_step_email(self, subscriber)
    else
      puts "error"
    end
  end
end
