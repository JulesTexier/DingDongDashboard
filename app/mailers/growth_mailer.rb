class GrowthMailer < ApplicationMailer
  # default delivery_method: :smtp
  default delivery_method: :postmark

  def send_growth_email_gmail(sequence_step, subscriber, property_data)
    marketing_link = !sequence_step.sequence.marketing_link.nil? ? sequence_step.sequence.marketing_link : "https://hellodingdong.com"
    # @tracking_link = marketing_link + "?ss=" + sequence_step.id.to_s + "&id=" + subscriber.id.to_s
    @sender_name = sequence_step.sequence.sender_name
    @content = sequence_step.content
    @property_data = "Ref : #{property_data[:ref]} (#{property_data[:price]} € - #{property_data[:surface]} m2)"
    sender_email = sequence_step.sequence.sender_email
    sender_email = "christophe@lafonciere1972.fr" if sender_email == "lafonciere1972@gmail.com"
    mail(from: sender_email, to: subscriber.email, subject: sequence_step.subject)
    mail.delivery_method.settings = { api_token: "bb96b996-cf88-487a-bdb2-44be28e2c411" }
    
    # mail.delivery_method.settings = {
    #   :address => "smtp.gmail.com",
    #   :port => 587,
    #   :user_name => sequence_step.sequence.sender_email,
    #   :password => ENV["GMAIL_GROWTH_PASSWORD"],
    #   :authentication => "plain",
    #   :domain => "gmail.com",
    #   :enable_starttls_auto => true,
    # }
  end
end
