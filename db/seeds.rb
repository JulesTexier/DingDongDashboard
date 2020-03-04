Subscriber.destroy_all
Property.destroy_all
Area.destroy_all
SelectedArea.destroy_all


# AREA REFERENCES
i= 1 
9.times do 
    a = Area.new
    a.name = "7500" + i.to_s
    i += 1
    a.save
    puts a.id
end

i= 10 
11.times do 

    a = Area.new
    a.name = "750" + i.to_s
    i += 1
    a.save
    puts a.id
end




# Subscribers for testing purposes
firtnames = ['Fred', 'Nico', 'Max', 'Etienne', 'Greg']
lastnames = ['Bnd', 'Fndz', 'Segrelove', 'Peta', 'Rouxel']
facebook_ids = ['2827641220632020', '2958957867501201', '2664254900355057', '2838363072915181', '2814291661948054']
max_prices = [500000, 450000, 300000, 600000, 1000000]
min_surfaces = [50, 45, 30, 60, 100]
min_rooms_numbers = [2, 2, 2, 3, 3]
min_floors = [0, 1, 0, 2, 4]
min_elevator_floors = [3, 3, 3, 3, 3]


i = 0 
5.times do

    s = Subscriber.new
    s.firstname = firtnames[i]
    s.lastname = lastnames[i]
    s.facebook_id = facebook_ids[i]
    s.max_price = max_prices[i]
    s.min_surface = min_surfaces[i]
    s.min_rooms_number = min_rooms_numbers[i]
    s.min_floor = min_floors[i]
    s.min_elevator_floor = min_elevator_floors[i]

    s.save

    i += 1

end

# Selected Area 
Subscriber.all.each do |sub|
    5.times do 
        sa = SelectedArea.new 
        sa.area = Area.order(Arel.sql('RANDOM()')).first
        sa.subscriber = sub 
        sa.save 
    end
end

# Properties
100.times do 

    p = Property.new 
    p.price = rand(200000..1000000)
    p.surface = (p.price / rand(9..14)).to_i
    p.area = Area.order(Arel.sql('RANDOM()')).first.name
    p.title = "Magnifique bien, Paris #{p.area}"
    p.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis mauris est, venenatis aliquam mi et, blandit aliquam enim. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam erat volutpat. Vestibulum luctus convallis ex, in volutpat felis volutpat tristique. In ullamcorper fringilla nunc, sed rutrum mi ullamcorper vitae. Aenean in euismod velit, nec faucibus neque. Etiam pulvinar sem purus, et eleifend sapien lacinia in. Aliquam imperdiet leo mi, in ultrices purus tempus placerat. Integer accumsan est nec orci aliquam pulvinar. Mauris tempor, ligula id euismod euismod, neque libero blandit sapien, eu fringilla nisi elit et lorem. "
    p.rooms_number = rand(1..3)
    p.link = "https://leboncoin.fr"
    p.source = ["LeBonCoin", "SeLoger", "SuperImmo", "PAP"].sample
    p.source == "PAP" ? p.provider = "Particulier" : p.provider = ["Agence", "Particulier", "N/A"].sample
    p.floor = [0, 1, 2, 3, 4, 5, nil, nil, nil].sample
    p.has_elevator = [true, false, nil, nil, nil].sample
    p.contact_number = ["0600000000", "N/C"].sample

    p.save

end