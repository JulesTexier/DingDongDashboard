Area.all.each do |area|
  area.update(zone: "Paris")
end

# Property.last(2).each do |property|
#   property.update(area: Area.where(name: property.old_area).first)
# end