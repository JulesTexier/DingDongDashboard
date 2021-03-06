require "postmark-rails/templated_mailer"
require 'dotenv/load'

class PostmarkMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin
  include Rails.application.routes.url_helpers

  # A virer (voire remanier avec le nouveau mode d'activation )
  def send_error_message_broker_btn(card_id, broker_firstname = "XXX")
    self.template_model = { broker_name: broker_firstname, card_id: card_id }
    mail from: "fred@hellodingdong.com", to: "etienne@hellodingdong.com", postmark_template_alias: "error-broker-btn"
  end

  def send_nurturing_email(subscriber, nurturing_email)
    self.template_model = { 
      subscriber_id: subscriber.id,
      subscriber_firstname: subscriber.firstname,
      subscriber_lastname: subscriber.lastname,
      subscriber_auth_token: subscriber.auth_token,
      broker_id: subscriber.broker.id,
      broker_firstname: subscriber.broker.firstname,
      broker_lastname: subscriber.broker.lastname,
      broker_email: subscriber.broker.email,
      broker_phone: subscriber.broker.phone,
      broker_avatar: ENV["BASE_URL"] + rails_blob_url(subscriber.broker.avatar, only_path: true),
      notary_id: subscriber.notary.id,
      notary_firstname: subscriber.notary.firstname,
      notary_lastname: subscriber.notary.lastname,
      notary_email: subscriber.notary.email,
      notary_phone: subscriber.notary.phone,
      notary_avatar: ENV["BASE_URL"] + rails_blob_url(subscriber.notary.avatar, only_path: true),
      contractor_id: subscriber.contractor.id,
      contractor_firstname: subscriber.contractor.firstname,
      contractor_lastname: subscriber.contractor.lastname,
      contractor_email: subscriber.contractor.email,
      contractor_phone: subscriber.contractor.phone,
      contractor_avatar: ENV["BASE_URL"] + rails_blob_url(subscriber.contractor.avatar, only_path: true)
    }
    mail from: "annonces@hellodingdong.com", to: subscriber.email, postmark_template_alias: nurturing_email.template
  end
end
