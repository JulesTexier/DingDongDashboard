require 'postmark-rails/templated_mailer'

class PostmarkMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin

  def send_chatbot_link(lead)
    self.template_model = { name: lead.name, actionmm_url: lead.get_chatbot_link, broker_name:lead.broker.firstname, broker_phone: lead.broker.phone, broker_email: lead.broker.email }
    mail from: 'etienne@hellodingdong.com', to: lead.email, postmark_template_alias: 'welcome'
  end

  def send_error_message_broker_btn(card_id, broker_firstname = "XXX")
    self.template_model = { broker_name: broker_firstname, card_id: card_id}
    mail from: 'fred@hellodingdong.com', to: "etienne@hellodingdong.com", postmark_template_alias: 'error-broker-btn'
  end
end
