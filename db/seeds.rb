require 'mongo'
require 'typhoeus'

MONGODB_CA_CERT = "./sg.crt"
options = { ssl:true, ssl_verify: true, :ssl_ca_cert => MONGODB_CA_CERT }
MONGODB_CONN_URL='mongodb://production00:PgxSkzjHvnpAdWR2@SG-ClusterDD-24238.servers.mongodirector.com:49409,SG-ClusterDD-24239.servers.mongodirector.com:49409,SG-ClusterDD-24240.servers.mongodirector.com:49409/giant-tiger-production?replicaSet=RS-ClusterDD-0&ssl=true'
@tiger = Mongo::Client.new(MONGODB_CONN_URL, options)



good = ['2827641220632020', '2958957867501201']


target = subs = @tiger[:subscribers].find(is_active: true, type:"to_buy", favorites: { '$exists' => true, '$not' => {'$size'=> 0}} ).sort(_id: -1)
# target = subs = @tiger[:subscribers].find(is_active: true, type:"to_buy", facebook_id: { '$in' => good} ).sort(_id: -1)



sub_save = []

target.each do |sub|
	if !sub['favorites'].empty?
		sub_hash = {}
		sub_hash[:facebook_id] = sub['facebook_id']
		sub_hash[:fav] = sub['favorites']
		sub_save.push(sub_hash)
	end
end

puts "#{sub_save.length} subs with favs have been saved"

File.open("./dump_favorites.json","w") do |f|
  f.write(sub_save.to_json)
end


# ============================================
# AGREGATION DES IDS DES PROPERTY A CREER DEPUIS LES FAVS
# ============================================

file = File.read('./dump_favorites.json')
data_hash = JSON.parse(file)

# selected_sub =  data_hash.select {|data| data["facebook_id"] == "2769799793141765"}

total_props_id = []

data_hash.each do |data| 
	total_props_id.concat data["fav"]
end


total_props_id = total_props_id.uniq
puts "#{total_props_id.length} unic properties"



# ==========================
# MERGER LES LAST 15j PROPERTIES 
# ==========================
total_props_hist = []

time = Time.parse('22:00:00 +0100')
borne_inf = BSON::ObjectId.from_time(time - (15*24*60*60))
borne_sup = BSON::ObjectId.from_time(time - (12*60*60))

hist_properties = @tiger[:scrapped_properties].find(
      type: 'to_buy',
      _id: { '$gte' => borne_inf, '$lte' => borne_sup },
    ).sort(_id: -1)

hist_properties.each do |prop|
	total_props_hist.push(prop["_id"])
end


total_props_id.concat total_props_hist
total_props_id = total_props_id.uniq

bson_array = []

total_props_id.each do |id|
	bson_array.push(BSON::ObjectId(id))
end



properties = @tiger[:scrapped_properties].find({_id: {'$in' => bson_array }})
puts "#{properties.count} props to create"


# ======================== 
# CREATION DES PROPERTIES
# ======================== 
props_x_ref_hash = []

properties.each do |prop|

	postgre_prop = Property.new

	postgre_prop.link = prop['link']
	postgre_prop.flat_type = prop['flat_type']
	postgre_prop.surface = prop['surface']
	postgre_prop.rooms_number = prop['rooms_number']
	postgre_prop.bedrooms_number = prop['bedrooms_number']
	postgre_prop.description = prop['description']
	postgre_prop.price = prop['rent']
	postgre_prop.area = prop['area']
	postgre_prop.source = prop['source']
	postgre_prop.renovated = prop['renovated']
	postgre_prop.title = prop['title']
	postgre_prop.reference = prop['reference']
	postgre_prop.has_been_processed = true
	postgre_prop.created_at = prop['_id'].generation_time


	# Gestion du provider
	if prop['is_agency']
		postgre_prop.provider = "Agence"
	elsif !prop['is_agency']
		postgre_prop.provider = "Particulier"
	end

	# Cas de l'étage 
	case prop['floor']

		when "Rez de chaussee"
			postgre_prop.floor = 0
		when "1er etage"
			postgre_prop.floor = 1
		when "2eme etage"
			postgre_prop.floor = 2
		when "3eme etage"
			postgre_prop.floor = 3
		when "4eme etage"
			postgre_prop.floor = 4
		when "5eme etage"
			postgre_prop.floor = 5
		when "6eme etage"
			postgre_prop.floor = 6
		when "7eme etage"
			postgre_prop.floor = 7
		when "8eme etage"
			postgre_prop.floor = 8
		when "9eme etage"
			postgre_prop.floor = 9
		else
			postgre_prop.floor = nil
		end

	# Gestiond de l'ascenseur
	case prop['lift']

		when "Avec ascenseur"
			postgre_prop.has_elevator = true
		when "Sans ascenseur"
			postgre_prop.has_elevator = false
		else
			postgre_prop.has_elevator = nil
		end

	postgre_prop.save

	# Création des images
	prop['image'].each do |image_url|
		i = PropertyImage.new
		i.url = image_url
		i.property = postgre_prop
		i.save 
	end

  prop_x_ref = {}
	prop_x_ref[:mongo_id] = prop['_id']
	prop_x_ref[:id] = postgre_prop.id
	props_x_ref_hash.push(prop_x_ref)

end



target.each do |sub|
	sub['favorites'].each do |prop_id|
		p = []
		p = props_x_ref_hash.select do |prop| 
			prop[:mongo_id] == BSON::ObjectId(prop_id)
		end
		if !p.empty?
			puts postgre_prop_id = p[0][:id]

			f = Favorite.new
			pg_sub = Subscriber.where(facebook_id: sub['facebook_id']).first
      if !pg_sub.nil?
        f.subscriber = pg_sub
        f.property_id = postgre_prop_id

        if !f.save
          "Probleme avec le subscriber #{Subscriber.where(facebook_id: sub['facebook_id']).first.id} for supposed property #{postgre_prop_id}"
        end
      end
    else
      puts "Empty element"
		end

	end
end




