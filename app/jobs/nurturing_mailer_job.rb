class NurturingMailerJob < ApplicationJob
  queue_as :mailers

  def perform(*args)
    ## args[0] is Subscriber
    ## args[1] is nurturing mailer info
    PostmarkMailer.send_nurturing_email(args[0], args[1]).deliver_now if args[0].is_active
  end
end
