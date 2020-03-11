require 'mongo'
require 'typhoeus'

MONGODB_CA_CERT = "./sg.crt"
options = { ssl:true, ssl_verify: true, :ssl_ca_cert => MONGODB_CA_CERT }
MONGODB_CONN_URL='mongodb://staging00:6rgsPeTykgy4VTrz@SG-ClusterDD-24238.servers.mongodirector.com:49409,SG-ClusterDD-24239.servers.mongodirector.com:49409,SG-ClusterDD-24240.servers.mongodirector.com:49409/giant-tiger-staging?replicaSet=RS-ClusterDD-0&ssl=true'
@tiger = Mongo::Client.new(MONGODB_CONN_URL, options)


Subscriber.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("subscribers")
Property.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("properties")
Area.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("areas")
SelectedArea.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("selected_areas")
PropertyImage.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("property_images")


# AREA REFERENCES
i = 1
9.times do
  a = Area.new
  a.name = "7500" + i.to_s
  i += 1
  a.save
  puts a.id
end

i = 10
11.times do
  a = Area.new
  a.name = "750" + i.to_s
  i += 1
  a.save
  puts a.id
end

# Subscribers

subs_to_copy = @tiger[:subscribers].find({is_active: true, type: "to_buy"})
puts "#{subs_to_copy.count} à copier"

subs_to_copy.each do |sub_to_copy|
  # sub_to_copy = subs_to_copy.first
  sub = Subscriber.new
  sub.firstname = sub_to_copy['firstname']
  sub.lastname = sub_to_copy['lastname']
  sub.email = sub_to_copy['email']
  sub.phone = sub_to_copy['phone']
  sub.facebook_id = sub_to_copy['facebook_id']
  sub.is_active = sub_to_copy['is_active']
  sub.created_at = sub_to_copy['created_at']
  sub.max_price = sub_to_copy['search_criteria'][0]['buy_price_max']
  sub.min_surface = sub_to_copy['search_criteria'][0]['surface_min']
  sub.min_rooms_number = sub_to_copy['search_criteria'][0]['rooms_number']
  sub.min_floor = sub_to_copy['search_criteria'][0]['min_floor']
  sub.min_elevator_floor = sub_to_copy['search_criteria'][0]['min_floor_elevator']


  sub.save

  puts "*"*10
  sub_to_copy['search_criteria'][0]['areas'].each do |area|
    # puts area
    sa = SelectedArea.new
    # puts sub
    sa.subscriber = sub
    sa.area = Area.where(name: area).first
    sa.save!
  end

  puts "*"*10
  puts sub.facebook_id

    ## J'appelle GetInfos de ManyChat en get pour avoir les informations d'un subscriber via son facebook_id
    get_infos_request = Typhoeus::Request.new(
      "https://api.manychat.com/fb/subscriber/getInfo?subscriber_id=#{sub.facebook_id}",
      method: :get,
      headers: { "Content-type" => "application/json", "Authorization" => "Bearer 93323:2a21d906a553fb6bb3e7cb3101bd3ff8"  },
    )
    get_infos_request.run

    # puts get_infos_request.to_s

    response = JSON.parse(get_infos_request.response.options[:response_body])

    # Je loop dans le hash et récupère les datas des custom_fields
    response["data"]["custom_fields"].each do |cusfield|
      # Dés que j'atteins un custom field dont le nom est "ID"
      # je fais une requete pour updaté son custom field fiavec sa nouvelle ID
      # puts cusfield = cusfield[]
      if cusfield["name"] == "id"
        body_request = {}
        # Je fais un hash ISO manychat
        body_request[:subscriber_id] = sub.facebook_id
        body_request[:field_name] = "id"
        body_request[:field_value] = sub.id.to_s ## <- TA NEW ID
        puts body_request.to_json
        # Je fais la requete post de set Custom Field
        set_custom_field_request = Typhoeus::Request.new(
          "https://api.manychat.com/fb/subscriber/setCustomFieldByName",
          method: :post,
          body: body_request.to_json,
          headers: { "Content-type" => "application/json", "Authorization" => "Bearer 93323:2a21d906a553fb6bb3e7cb3101bd3ff8" },
        )
        set_custom_field_request.run
        # puts JSON.parse(set_custom_field_request.response.options[:response_body])

        body_request = {}
        # Je fais un hash ISO manychat
        body_request[:subscriber_id] = sub.facebook_id
        body_request[:field_name] = "criteria_page"
        body_request[:field_value] = "https://giant-cat-staging.herokuapp.com/subscribers/#{sub.id.to_s}/edit" ## <- TA NEW ID
        puts body_request.to_json
        # Je fais la requete post de set Custom Field
        set_custom_field_request = Typhoeus::Request.new(
          "https://api.manychat.com/fb/subscriber/setCustomFieldByName",
          method: :post,
          body: body_request.to_json,
          headers: { "Content-type" => "application/json", "Authorization" => "Bearer 93323:2a21d906a553fb6bb3e7cb3101bd3ff8" },
        )
        set_custom_field_request.run

      end
    end

  # sub_to_copy['search_criteria'][0]['areas'].each do |area|
  #   sa = SelectedArea.new(subscriber: s, area: Area.all.first)
  #   # sa = SelectedArea.new(subscriber: s, area: Area.where(name: area).first)
	#   sa.save
  # end


  # if sub_to_copy['favorites'].length > 0
  #   f = Favorite.new 
  #   f.subscriber = s
  # end

end

def update_manychat(subscriber)
  
end