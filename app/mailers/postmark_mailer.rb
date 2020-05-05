require "postmark-rails/templated_mailer"

class PostmarkMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin

  def send_new_lead_notification_to_broker(lead)
    self.template_model = { broker_firstname: lead.broker.firstname, lead_info: lead.get_fullname, trello_board_url: lead.broker.get_board_url }
    mail from: "etienne@hellodingdong.com", to: lead.broker.email, postmark_template_alias: "broker-new-lead-notification"
  end

  def send_chatbot_link(user)
    self.template_model = { name: user.firstname, action_url: user.get_chatbot_link, broker_name: user.broker.firstname, broker_phone: user.broker.phone, broker_email: user.broker.email }
    mail from: "etienne@hellodingdong.com", to: user.email, postmark_template_alias: "welcome"
  end

  def send_new_lead_notification_to_broker(lead)
    self.template_model = { broker_firstname: lead.broker.firstname, lead_info: lead.get_fullname, trello_board_url: lead.broker.get_board_url }
    mail from: "etienne@hellodingdong.com", to: lead.broker.email, postmark_template_alias: "broker-new-lead-notification"
  end

  def send_user_dulicate_email(user)
    self.template_model = { lead_firstname: user.firstname }
    mail from: "etienne@hellodingdong.com", to: user.email, postmark_template_alias: "lead-duplicate"
  end

  def send_email_to_lead_with_no_messenger(lead)
    self.template_model = { lead_firstname: lead.firstname }
    mail from: "etienne@hellodingdong.com", to: lead.email, postmark_template_alias: "lead-no-messenger"
  end

  def send_error_message_broker_btn(card_id, broker_firstname = "XXX")
    self.template_model = { broker_name: broker_firstname, card_id: card_id }
    mail from: "fred@hellodingdong.com", to: "etienne@hellodingdong.com", postmark_template_alias: "error-broker-btn"
  end

  def send_onboarding_hunter_email(lead)
    self.template_model = { lead_firstname: lead.firstname }
    mail from: "etienne@hellodingdong.com", to: lead.email, bcc: "maxime@hellodingdong.com", postmark_template_alias: "onboarding-hunter"
  end
end
