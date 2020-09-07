class NurturingMailerJob < ApplicationJob
  queue_as :mailers

  def perform(*args)
    PostmarkMailer.send_nurturing_email(args[0], args[1]).deliver_now if args[0].is_active
  end
end
