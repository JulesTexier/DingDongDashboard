require "typhoeus"


subsc_to_update = Subscriber.last(311)
# subsc_to_update = Subscriber.first(1)
c= 0

subsc_to_update.each do |sub|
  # //Update elvator
  sub.update(min_elevator_floor: nil) if sub.min_elevator_floor = 0

  get_infos_request = Typhoeus::Request.new(
    "https://api.manychat.com/fb/subscriber/getInfo?subscriber_id=#{sub.facebook_id}",
    method: :get,
    headers: { "Content-type" => "application/json", "Authorization" => "Bearer 32033:830388137d55fee675e37f80a21dde21" },
  )
  get_infos_request.run

  response = JSON.parse(get_infos_request.response.options[:response_body])

  if response["status"] != "error"
    puts "Subscriber fetched"

    body_request = {}
    # Je fais un hash ISO manychat
    body_request[:subscriber_id] = sub.facebook_id
    body_request[:field_name] = "id"
    body_request[:field_value] = sub.id.to_s
    puts body_request.to_json
    # Je fais la requete post de set Custom Field
    set_custom_field_request = Typhoeus::Request.new(
      "https://api.manychat.com/fb/subscriber/setCustomFieldByName",
      method: :post,
      body: body_request.to_json,
      headers: { "Content-type" => "application/json", "Authorization" => "Bearer 32033:830388137d55fee675e37f80a21dde21" },
    )
    set_custom_field_request.run

    body_request = {}
    # Je fais un hash ISO manychat
    body_request[:subscriber_id] = sub.facebook_id
    body_request[:field_name] = "criteria_page"
    body_request[:field_value] = "https://giant-cat.herokuapp.com/subscribers/#{sub.id.to_s}/edit" ## <- TA NEW ID
    puts body_request.to_json
    # Je fais la requete post de set Custom Field
    set_custom_field_request = Typhoeus::Request.new(
      "https://api.manychat.com/fb/subscriber/setCustomFieldByName",
      method: :post,
      body: body_request.to_json,
      headers: { "Content-type" => "application/json", "Authorization" => "Bearer 32033:830388137d55fee675e37f80a21dde21" },
    )
    set_custom_field_request.run
	else
		"Le subscriber n'est plus dans votre audience Manychat !" 	
		c += 1
  end
end

puts "#{c} subs en base ne sont plus dans votre audience ! (sur les 311 traités)"
