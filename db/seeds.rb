total = Property.all.count
properties = Property.all
i = 0

properties.each do |property|
  property_images = PropertyImage.where(property_id: property.id)
  images = []
  property_images.each do |property_image|
    images.push(property_image.url)
  end
  property.update(images: images)
  i += 1
  puts "Property #{i} / #{total}"
end
