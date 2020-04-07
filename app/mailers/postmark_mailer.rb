require 'postmark-rails/templated_mailer'

class PostmarkMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin

  def chatbot_link
    mail(
      :subject => 'Accède au chatbot DingDong !',
      :to  => 'fred@hellodingdong.com',
      :from => 'fred@hellodingdong.com',
      :track_opens => 'true')
  end

  def send_chatbot_link(lead)
    self.template_model = { name: lead.name, action_url: lead.get_chatbot_link, broker_name:lead.broker.firstname, broker_phone: lead.broker.phone, broker_email: lead.broker.email }
    mail from: 'fred@hellodingdong.com', to: lead.email, postmark_template_alias: 'welcome'
  end
end
