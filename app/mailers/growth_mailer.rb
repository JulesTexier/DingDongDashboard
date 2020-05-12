class GrowthMailer < ApplicationMailer

  default delivery_method: :smtp

  def send_growth_email_gmail(sequence_step, subscriber)
    @content =  sequence_step.content
    mail(from: sequence_step.sequence.sender_email, to: subscriber.email, subject: sequence_step.subject)
    mail.delivery_method.settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :user_name            => sequence_step.sequence.sender_email,
      :password             => ENV['GMAIL_GROWTH_PASSWORD'],
      :authentication       => "plain",
      :domain               => 'gmail.com',
      :enable_starttls_auto => true
    }
  end
  
end
