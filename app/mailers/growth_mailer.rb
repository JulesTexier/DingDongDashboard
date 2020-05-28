class GrowthMailer < ApplicationMailer
  default delivery_method: :smtp

  def send_growth_email_gmail(sequence_step, subscriber, property_data)
    @tracking_link = "https://hellodingdong.com/home.html?ss=" + sequence_step.id.to_s + "&id=" + subscriber.id.to_s
    @sender_name = sequence_step.sequence.sender_name
    @content = sequence_step.content
    @property_data = "Ref : #{property_data[:ref]} (#{property_data[:price]} € - #{property_data[:surface]} m2)"
    mail(from: "#{@sender_name} <#{sequence_step.sequence.sender_email}>", to: subscriber.email, subject: sequence_step.subject)
    mail.delivery_method.settings = {
      :address => "smtp.gmail.com",
      :port => 587,
      :user_name => sequence_step.sequence.sender_email,
      :password => ENV["GMAIL_GROWTH_PASSWORD"],
      :authentication => "plain",
      :domain => "gmail.com",
      :enable_starttls_auto => true,
    }
  end
end
