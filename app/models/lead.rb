class Lead < ApplicationRecord

  belongs_to :broker

  def trello_description
    desc = ""
    desc += "**CONTACT** \u000A Tél: #{self.phone} \u000A Email: #{self.email}\u000A"
    desc += "\u000A**PROJET**\u000A"
    desc += "\u000A**FINANCEMENT**\u000A"
    desc += "\u000A**CLIENTE**\u000A"
    desc += "\u000A**NOTES**\u000A"
    desc += "\u000A\u000A---\u000A\u000A"
    desc += trello_summary
  end

  def trello_summary
    desc = ""
    desc += "**#{self.name.upcase}**"
    desc += "\u000A**Projet d'achat** : #{self.project_type}"
    desc += "\u000A**Budget Maximum** : #{self.max_price.to_s.reverse.gsub(/...(?=.)/,'\& ').reverse} €"
    desc += "\u000A**Surface Minimum ** : #{self.min_surface} m2"
    desc += "\u000A**Arrondissements** : #{self.areas}"
    desc += "\u000A\u000A**#{self.name} a déclaré ne pas avoir Messenger**" if !self.has_messenger
    desc += "\u000A\u000A*Inscription chez DingDong : #{self.created_at.strftime("%d/%m/%Y - %H:%M")}*"
  end

  def get_chatbot_link
    return "https://m.me/HiDingDong"
  end


end
