class Lead < ApplicationRecord

  def generate_trello_description
    desc = ""
    desc += "**CONTACT** \u000A Tél: #{self.phone} \u000A Email: #{self.email}"
    desc += "\u000A**PROJET**"
    desc += "\u000A**FINANCEMENT**"
    desc += "\u000A**CLIENTE**"
    desc += "\u000A**NOTES**"
  end

  def trello_summary
    desc = ""
    desc += "**Projet d'achat** : #{self.project_type}"
    desc += "\u000A**Budget Maximum** : #{self.max_price}"
    desc += "\u000A**Surface Minimum Maximum** : #{self.min_surface}"
  end


end
