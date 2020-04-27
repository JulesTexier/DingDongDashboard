Area.all.each do |area|
  area.update(zone: "Paris")
end

total = Property.all.size
i = 1

Property.all.each do |property|
  puts "Update property #{i}/#{total} "
  property.update(area: Area.where(name: property.old_area).first)
  i += 1
end

Property.where(old_area: "75116").update_all(area_id: Area.where(name: "75016").first.id)

area_yaml = YAML.load_file("db/data/areas.yml")

area_yaml.each do |district_data|
  if district_data["zone"] == "Paris"
    district_data["datas"].each do |data|
      Area.where(name: data["terms"][0]).first.update(name: data["name"])
    end
  end
end

area_yaml.each do |district_data|
  if district_data["zone"] == "Banlieue-Ouest"
    district_data["datas"].each do |data|
      Area.create(name: data["name"], zone: "Banlieue-Ouest")
    end
  end
end
