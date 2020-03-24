require 'csv'

class StaticPagesController < ApplicationController
  def dashboard

    # properties
    @properties_last_24h = Property.where("created_at > ?", 24.hours.ago)
    @properties_last_48h = Property.where("created_at > ?", 48.hours.ago)
    (@properties_last_48h.count - @properties_last_24h.count) != 0 ? @growth24h_props = (@properties_last_24h.count * 100) / (@properties_last_48h.count - @properties_last_24h.count) - 100 : "N/A"

    @properties_last_1m = Property.where("created_at > ?", 1.months.ago)
    @properties_last_2m = Property.where("created_at > ?", 2.months.ago)
    (@properties_last_2m.count - @properties_last_1m.count) != 0 ? @growth1m_props = (@properties_last_1m.count * 100) / (@properties_last_2m.count - @properties_last_1m.count) - 100 : "N/A"

    @properties_last_1w = Property.where("created_at > ?", 1.weeks.ago)
    @properties_last_2w = Property.where("created_at > ?", 2.weeks.ago)
    (@properties_last_2w.count - @properties_last_1w.count) != 0 ? @growth1w_props = (@properties_last_1w.count * 100) / (@properties_last_2w.count - @properties_last_1w.count) - 100 : "N/A"

    # subs
    @subs_last_24h = Subscriber.where("created_at > ?", 24.hours.ago)
    @subs_last_48h = Subscriber.where("created_at > ?", 48.hours.ago)
    (@subs_last_48h.count - @subs_last_24h.count) != 0 ? @growth24h_subs = (@subs_last_24h.count * 100) / (@subs_last_48h.count - @subs_last_24h.count) - 100 : "N/A"

    @subs_last_1m = Subscriber.where("created_at > ?", 1.months.ago)
    @subs_last_2m = Subscriber.where("created_at > ?", 2.months.ago)
    (@subs_last_2m.count - @subs_last_1m.count) != 0 ? @growth1m_subs = (@subs_last_1m.count * 100) / (@subs_last_2m.count - @subs_last_1m.count) - 100 : "N/A"

    @subs_last_1w = Subscriber.where("created_at > ?", 1.weeks.ago)
    @subs_last_2w = Subscriber.where("created_at > ?", 2.weeks.ago)
    (@subs_last_2w.count - @subs_last_1w.count) != 0 ? @growth1w_subs = (@subs_last_1w.count * 100) / (@subs_last_2w.count - @subs_last_1w.count) - 100 : "N/A"
  end

  def properties
    @total = Property.all.count
    # @total1m = Property.where('created_at > ?', 30.days.ago).count
    # @total24h = Property.where('created_at > ?', 24.hours.ago).count

    # sites = Property.distinct.pluck(:source)
    @data = []
    sites.each do |source|
      @data.push({ source: source, count: Property.where(source: source).count })
    end

    # @data24h = []
    # sites.each do |source|
    #     @data24h.push({source: source, count: Property.where('source = ? AND created_at > ?', source, 24.hours.ago).count})
    # end

    # @data1m = []
    # sites.each do |source|
    #     @data1m.push({source: source, count: Property.where('source = ? AND created_at > ?', source, 30.days.ago).count})
    # end
  end

  def stats
    # @properties = Property.all
    @subscribers = Subscriber.where(is_active: true)
    facebook_ids_blacklist = ["2827641220632020", "2958957867501201", "2838363072915181", "2814291661948054", "2664254900355057"]
    # nb_ads = []
    # @subscribers.each do |sub|
    #     c = 0
    #     @properties.each do |p|
    #         if sub.is_matching_property?(p)
    #             c += 1
    #         end
    #     nb_ads.push(c)
    #     end
    # end
    # @moyenne = (nb_ads.inject{ |sum, el| sum + el }.to_f / nb_ads.size).to_i

    date = Date.parse("march 1 2020")
    @properties_feb = Property.where("created_at > ?", date)
    @nb_ads_feb = []
    @subscribers.each do |sub|
      d = 0
      if !(facebook_ids_blacklist.include? sub.facebook_id)
        @properties_feb.each do |p|
          if sub.is_matching_property?(p)
            d += 1
          end
        end
        @nb_ads_feb.push(d) if d > 5
      end
    end
    @number_days = DateTime.now.mjd - date.mjd
    @moyenne_feb = (@nb_ads_feb.inject { |sum, el| sum + el }.to_f / @nb_ads_feb.size).to_i
  end

  def chart
    # @data =  [["2020-01-14",4], ["2020-01-14",3],["2020-01-15",0],["2020-01-16",0]]

    # @csv = CSV.read("app/services/broadcasters/data/logs.csv")

    # @data = []
    # @csv.each do |line|
    #   hash_data = {}
    #   hash_data["subscriber"] = line[1]
    #   hash_data["nb_props"] = line[2]
    #   @data.push(hash_data)
    # end    
  end

  def property_price
    props = Property.where("surface > 0 AND price > 0").select(:surface, :price, :area, :created_at).order('created_at ASC')
    colors = ['#FF6633', '#FFB399', '#FF33FF', '#FFFF99', '#00B3E6', 
		  '#E6B333', '#3366E6', '#999966', '#99FF99', '#B34D4D',
		  '#80B300', '#809900', '#E6B3B3', '#6680B3', '#66991A', 
		  '#FF99E6', '#CCFF1A', '#FF1A66', '#E6331A', '#33FFCC']
    averages = []
    areas = Area.all.pluck(:name)
    areas.each_with_index do |area, area_index|
      averages[area_index] = []
      averages[area_index][0] = area
      averages[area_index][1] = []
      averages[area_index][2] = colors[area_index]
      props_xx = props.reject { |prop| prop.area != area }.group_by { |prop| prop.created_at.month}
      props_xx.each do |key, value| 
        # byebug
        props_xx.fetch(key).each_with_index do |prop_xx, index|
          if prop_xx.surface.to_i > 0
            props_xx.fetch(key)[index] = (prop_xx.price/prop_xx.surface.round(2)) 
          else 
            props_xx.fetch(key).delete(index)
          end
        end
        if props_xx.fetch(key).size > 0
          average_price = (props_xx.fetch(key).inject{ |sum, el| sum + el }.to_f / props_xx.fetch(key).size).round(0) 
          #  Insert data
          averages[area_index][1].push([Date::MONTHNAMES[key],average_price])
        end
        
      end


    end
    @chart_data = []
    averages.each do |area|
      area_hash = {}
      area_hash[:name] = area[0]
      area_hash[:data] = area[1]
      area_hash[:color] = area[2]
      @chart_data.push(area_hash)
    end


    # props_17 = props.reject { |prop| prop.area != "75017" }.group_by { |prop| prop.created_at.month}
    # averages_17 = []
    # props_17.each do |key, value| 
    #   puts key
    #   props_17.fetch(key).each_with_index do |prop_17, index|
    #     if prop_17.surface.to_i > 0
    #       props_17.fetch(key)[index] = (prop_17.price/prop_17.surface.round(2)) 
    #     else 
    #       props_17.fetch(key).delete(index)
    #     end
    #   end
    #   if props_17.fetch(key).size > 0
    #     average_price = (props_17.fetch(key).inject{ |sum, el| sum + el }.to_f / props_17.fetch(key).size).round(0) 
    #   end
    #   averages_17.push([Date::MONTHNAMES[key],average_price])
    # end

    # byebug
    # puts averages_17
  end

end
