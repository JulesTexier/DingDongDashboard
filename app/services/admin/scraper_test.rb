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

  def initialize(sc_id = nil)
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

  def seed
    agglo_file = YAML.load_file("db/data/agglomeration.yml")
    agglo_file.each do |agglo_data|
      agglo = Agglomeration.find_by(name: agglo_data["agglomeration"])
      if agglo.blank?
        a = Agglomeration.new
        a.name = agglo_data["agglomeration"]
        a.is_active = agglo_data["is_active"]
        a.ref_code = agglo_data["ref_code"]
        a.save
        agglo_data["zone"].each do |department|
          Department.create(name: department, agglomeration: a) unless Department.where(name: department).any?
        end
      else
        agglo.update(ref_code: agglo_data["ref_code"])
        agglo_data["zone"].each do |department|
          Department.create(name: department, agglomeration: agglo) unless Department.where(name: department).any?
        end
      end
    end

    area_yaml = YAML.load_file("./db/data/areas.yml")
    area_yaml.each do |district_data|
      district_data["datas"].each do |data|
        area = Area.find_by(name: data["name"])
        if area.nil?
          Area.create(name: data["name"], zone: district_data["zone"], zip_code: data["terms"].first, department: Department.find_by(name: district_data["zone"]))
          puts "Area - #{data["name"]} created"
        else 
          area.update(zone: district_data["zone"]) if area.zone != district_data["zone"]
          area.update(department: Department.find_by(name: area.zone)) if area.department.nil?
          area.update(zip_code: data["terms"].first) if area.zip_code != data["terms"].first
        end
      end
    end

    scraper_params = YAML.load_file("db/data/scraper_provisory.yml")
    new_scrapers_ids = []
    scraper_params.each do |param|
      param["params"].each do |data|
        s = ScraperParameter.new
        data["multi_page"] = false if data["multi_page"].nil?
        data["http_type"] = nil if data["http_type"].nil?
        data["http_request"] = [] if data["http_request"].nil?
        data["page_nbr"] = 1 if data["page_nbr"].nil?
        s.source = param["source"]
        s.zone = data["zone"]
        s.main_page_cls = data["main_page_cls"]
        s.scraper_type = data["scraper_type"]
        s.url = data["url"]
        s.multi_page = data["multi_page"]
        s.page_nbr = data["page_nbr"]
        s.http_type = data["http_type"]
        s.http_request = data["http_request"]
        s.group_type = data["group_type"]
        s.zone = data["zone"]
        s.high_priority = data["high_priority"] unless data["high_priority"].nil?
        if ScraperParameter.where(source: s.source, zone: s.zone, group_type: s.group_type, url: s.url).empty?
          if s.save
            new_scrapers_ids.push(s.id)
            puts "Insertion of parameters - #{s.source} - #{s.zone}"
          else
            puts "Error of parameter insertion"
          end
        end
      end
    end
    new_scrapers_ids
  end


  def launch_dedicated_sc(sc)
    begin
      source_name = sc.source == "Propr. Figaro" ? "ProprietesFigaro" :  sc.source == "PAP" ? "Pap" : sc.source
      scraper = Object.const_get("#{sc.group_type}::Scraper#{source_name}")
      sc.update(is_active: true)
      scraper.new(sc.id).launch(1)
      p = Property.last
      sc.update(is_active: false)
      if p.source == sc.source && Department.find_by(name: sc.zone).areas.pluck(:id).include?(p.area.id) 
        p.destroy 
        "[OK] Scaper works well"
      else 
        "[FAIL] Invalid Scraper"  
      end
    rescue NameError
      "Scraper not initialized, check group_type and source name - SC group_type : #{sc.group_type}, SC source : #{source_name}"
    end
  end

end