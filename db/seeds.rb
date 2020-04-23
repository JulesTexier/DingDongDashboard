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