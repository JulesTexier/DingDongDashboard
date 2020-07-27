require "postmark-rails/templated_mailer"
require 'dotenv/load'

class PostmarkMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin

  
  # A virer (voire remanier avec le nouveau mode d'activation )
  def send_error_message_broker_btn(card_id, broker_firstname = "XXX")
    self.template_model = { broker_name: broker_firstname, card_id: card_id }
    mail from: "fred@hellodingdong.com", to: "etienne@hellodingdong.com", postmark_template_alias: "error-broker-btn"
  end

  

  # A garder (remanier avec la table alert)
  def send_properties_to_hunters(hunter_search)
    self.template_model = { hunter_firstname: hunter_search.hunter.firstname, hunter_search_name: hunter_search.research_name, hunter_search_link: ENV['BASE_URL']+ "hunters/#{hunter_search.hunter.id}/hunter_searches/#{hunter_search.id}" }
    mail from: "etienne@hellodingdong.com", to: hunter_search.hunter.email, postmark_template_alias: "hunter-notification"
  end
end
