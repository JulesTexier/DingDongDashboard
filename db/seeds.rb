require "json"
Subway.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!("subways")
obj = JSON.parse(File.read("./db/data/subways.json"))
obj["stations"].each do |hsh|
  puts "***"
  puts Subway.create(name: hsh["metro"], line: hsh["ligne"])
end