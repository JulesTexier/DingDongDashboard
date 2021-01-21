class Admin::ScraperTest < ApplicationService


=begin
   PROCESS :
  0 • Faire un seed avec les nouveaux scrapers
  1 • Lancer le test, qui va : 
      a) Vérifier que le Department relié à la zone existe ? 
      b) Lancer le scraper et viérifer s'il récupère au moins 1 élément ?

  Que faire en cas d'erreur ? 

  • "Scraper Parameter with id <<ID>> not found " : Aucun objet avec l'id donné en paramètre n'existe dans la table ScraperParameter
  • "Deparment not found" : Le déparement portant le nom du champ "zone" du sp n'existe pas en base. Il faut le rajouter dans l'agglomération correspondante dans le fichier Agglomeration.yml et rejouer le seed
  • "Scraper not initialized, check group_type and source name" : le champ 'source' et/ou 'group_type' dans le sc n'est pas le bon => éditer le fichier scraper_parameter.yml en conséquence.
  • "Invalid scraper" : Le scraper n'a récupéra aucun bien, le problème peut venir de plein de source : mauvais paramétrage de l'url, aucun bien dispo sur l'url, probleme avec le scraper de la source, il ne trouve pas d'Area correspondante ...
=end

  attr_accessor :sc_id

  def initialize(sc_id)
    @sc_id = sc_id
  end

  def call
    begin
      puts "Starting test for ScraperParameter with id #{sc_id}"
      sc = ScraperParameter.find(@sc_id)
      Department.find_by(name: sc.zone).nil? ? "[FAIL] Deparment not found" : launch_dedicated_sc(sc)
    rescue ActiveRecord::RecordNotFound
      "Scraper Parameter with id #{sc_id} not found "
    end
  end

  def launch_dedicated_sc(sc)
    begin
      source_name = sc.source == "Propr. Figaro" ? "ProprietesFigaro" :  sc.source.split(" ").map{|item| item.capitalize}.join("")
      scraper = Object.const_get("#{sc.group_type}::Scraper#{source_name}").new(sc.id)
      sc.update(is_active: true)
      scraper.launch(1)
      p = Property.last
      sc.update(is_active: false)
      if p.source == sc.source && Department.find_by(name: sc.zone).areas.pluck(:id).include?(p.area.id) 
        p.destroy 
        "[OK] Scaper works well"
      else 
        "[FAIL] Invalid Scraper"  
      end
    rescue NameError
      "Scraper not initialized, check group_type and source name"
    end
  end

end