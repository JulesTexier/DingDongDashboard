leads = Lead.all

leads.each do |lead|
  old_areas = lead.areas 
  unless old_areas.nil?
    new_areas = old_areas.gsub("75001", "Paris 1er").gsub("75002", "Paris 2ème").gsub("75003", "Paris 3ème").gsub("75004", "Paris 4ème").gsub("75005", "Paris 5ème").gsub("75006", "Paris 6ème").gsub("75007", "Paris 7ème").gsub("75008", "Paris 8ème").gsub("75009", "Paris 9ème").gsub("75010", "Paris 10ème").gsub("75011", "Paris 11ème").gsub("75012", "Paris 12ème").gsub("75013", "Paris 13ème").gsub("75014", "Paris 14ème").gsub("75015", "Paris 15ème").gsub("75016", "Paris 16ème").gsub("75017", "Paris 17ème").gsub("75018", "Paris 18ème").gsub("75019", "Paris 19ème").gsub("75020", "Paris 20ème")
    lead.update(areas: new_areas)
  end
end

