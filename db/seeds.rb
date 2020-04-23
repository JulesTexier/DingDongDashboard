# Area.all.each do |area|
#   area.update(zone: "Paris")
# end

total = Property.all.size
i = 1

Property.all.each do |property|
  puts "Update property #{i}/#{total} "
  property.update(area: Area.where(name: property.old_area).first)
  i += 1
end