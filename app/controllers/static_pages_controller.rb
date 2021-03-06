require "csv"

class StaticPagesController < ApplicationController
  before_action :authenticate_admin

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

    # Evolution par sources
    @max = 0
    props = Property.where("created_at > ? ", Time.parse("29 february 2020")).select(:source, :created_at).order("created_at ASC")
    colors = ["#FF6633", "#FFB399", "#FF33FF", "#FFFF99", "#00B3E6",
              "#E6B333", "#3366E6", "#999966", "#99FF99", "#B34D4D",
              "#80B300", "#809900", "#E6B3B3", "#6680B3", "#66991A",
              "#FF99E6", "#CCFF1A", "#FF1A66", "#E6331A", "#33FFCC"]
    averages = []
    averages[0] = ["", [["W08", 0], ["W09", 0], ["W10", 0], ["W11", 0], ["W12", 0]], "#ffffff"]
    # sources = ["SeLoger"]
    sources = Property.all.pluck(:source).uniq!
    sources.each_with_index do |source, source_index|
      source_index += 1
      averages[source_index] = []
      averages[source_index][0] = source
      averages[source_index][1] = []
      averages[source_index][2] = colors[source_index]
      props_xx = props.reject { |prop| prop.source != source }.group_by { |source| source.created_at.strftime("%W") }
      props_xx.each do |key, value|
        total_props_in_period = value.length
        @max = total_props_in_period if total_props_in_period > @max
        averages[source_index][1].push(["W" + key, total_props_in_period])
      end
    end

    @chart_data = []
    @max += 10

    averages.each do |source|
      source_hash = {}
      source_hash[:name] = source[0]
      source_hash[:data] = source[1]
      source_hash[:color] = source[2]
      @chart_data.push(source_hash)
    end
  end

  def stats
    @subscribers = Subscriber.where(is_active: true)
    facebook_ids_blacklist = ["2827641220632020", "2958957867501201", "2838363072915181", "2814291661948054", "2664254900355057"]
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
  end

  def property_price
    props = Property.where.not(area: nil).where("surface > 0 AND price > 0").select(:surface, :price, :area, :created_at).order("created_at ASC")
    colors = ["#FF6633", "#FFB399", "#FF33FF", "#FFFF99", "#00B3E6",
              "#E6B333", "#3366E6", "#999966", "#99FF99", "#B34D4D",
              "#80B300", "#809900", "#E6B3B3", "#6680B3", "#66991A",
              "#FF99E6", "#CCFF1A", "#FF1A66", "#E6331A", "#33FFCC"]
    averages = []
    averages[0] = ["", [["01", 0], ["02", 0], ["03", 0], ["04", 0], ["05", 0], ["06", 0], ["07", 0], ["08", 0], ["09", 0], ["10", 0], ["11", 0], ["12", 0]], "#ffffff"]
    areas = Area.all.pluck(:name)
    areas.each_with_index do |area, area_index|
      area_index += 1
      averages[area_index] = []
      averages[area_index][0] = area
      averages[area_index][1] = []
      averages[area_index][2] = colors[area_index]
      props_xx = props.reject { |prop| prop.area.name != area }.group_by { |prop| prop.created_at.strftime("%W") }
      props_xx.each do |key, value|
        props_xx.fetch(key).each_with_index do |prop_xx, index|
          if prop_xx.surface.to_i > 0
            props_xx.fetch(key)[index] = (prop_xx.price / prop_xx.surface.round(2))
          else
            props_xx.fetch(key).delete(index)
          end
        end
        if props_xx.fetch(key).size > 0
          average_price = (props_xx.fetch(key).inject { |sum, el| sum + el }.to_f / props_xx.fetch(key).size).round(0)
          #  Insert data
          averages[area_index][1].push([key, average_price])
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
  end

  def sources
    @max = 0
    props = Property.where("created_at > ? ", Time.parse("29 february 2020")).select(:source, :created_at).order("created_at ASC")
    colors = ["#FF6633", "#FFB399", "#FF33FF", "#FFFF99", "#00B3E6",
              "#E6B333", "#3366E6", "#999966", "#99FF99", "#B34D4D",
              "#80B300", "#809900", "#E6B3B3", "#6680B3", "#66991A",
              "#FF99E6", "#CCFF1A", "#FF1A66", "#E6331A", "#33FFCC"]
    averages = []
    averages[0] = ["", [["W08", 0], ["W09", 0], ["W10", 0], ["W11", 0], ["W12", 0]], "#ffffff"]
    sources = Property.all.pluck(:source).uniq!
    sources.each_with_index do |source, source_index|
      source_index += 1
      averages[source_index] = []
      averages[source_index][0] = source
      averages[source_index][1] = []
      averages[source_index][2] = colors[source_index]
      props_xx = props.reject { |prop| prop.source != source }.group_by { |source| source.created_at.strftime("%W") }
      props_xx.each do |key, value|
        total_props_in_period = value.length
        @max = total_props_in_period if total_props_in_period > @max
        averages[source_index][1].push(["W" + key, total_props_in_period])
      end
    end

    @chart_data = []
    @max += 10

    averages.each do |source|
      source_hash = {}
      source_hash[:name] = source[0]
      source_hash[:data] = source[1]
      source_hash[:color] = source[2]
      @chart_data.push(source_hash)
    end
  end

  def duplicates
    @duplicated_props_this_week = Property.where("created_at >= ?", DateTime.now.beginning_of_day - 7.days).select(:price, :rooms_number, :surface).group(:price, :rooms_number, :surface).having("count(*) > 1")
    @duplicated_props_last_week = Property.where("created_at BETWEEN ? AND ?", DateTime.now.beginning_of_day - 14.days, DateTime.now.beginning_of_day - 7.days).select(:price, :rooms_number, :surface).group(:price, :rooms_number, :surface).having("count(*) > 1")
  end

  def general_broker_dashboard
    @broker_agencies = BrokerAgency.all
    # params = {year: 2021, month: 01}
    start_date = Time.parse("01/#{params[:month]}/#{params[:year]}")
    end_date = Time.parse("#{start_date.utc.end_of_month.day}/#{params[:month]}/#{params[:year]}") + 1.day
    @data = @broker_agencies.map do |ba|
        ba_data = {id: ba.id, name: ba.name, agglomeration: ba.agglomeration.name, contract_type: ba.only_dd_users ? "Ding Dong" : "Tout", status: ba.status, default_pricing_lead: ba.default_pricing_lead }
        period_subs = ba.get_subscribers(start_date, end_date)
        ba_data[:nb_leads] = period_subs.count
        ba_data[:nb_leads_dashboard] = period_subs.select{|s| s.created_at < Time.now - 7.days}.count
        ba_data[:nb_leads_ding_dong] = period_subs.select{|s| s.is_ding_dong_user?}.count
        ba_data[:nb_hot_leads] = period_subs.select{|s| s.hot_lead?}.count
        ba_data[:nb_leads_se_loger] = period_subs.select{|s| !s.is_ding_dong_user?}.count
        ba_data[:max_period_leads] = ba.max_period_leads
        ba_data[:current_paid_leads] = ba.only_dd_users ? ba_data[:nb_leads_ding_dong] : ba_data[:nb_leads_se_loger]
        ba_data[:progress] = (ba_data[:current_paid_leads].to_f / ba.max_period_leads.to_f)*100.round(2)
        ba_data
    end
    @ba_by_status = ["premium","test","free"].map{|plan_name| @data.sort_by { |k| k["nb_leads"] }.select{|ba| ba[:status] == plan_name}}
  end

  def agglomerations_dashboard
    @agglomerations = Agglomeration.all
  end

  def broker_agency_dashboard
    @broker_agency = params[:broker_id]
  end

  def handle_dd_courtage_lead
    @subscribers = BrokerAgency.find_by(name: "Ding Dong Courtage").get_subscribers
  end

  private
  def authenticate_admin
    redirect_to new_admin_session_path unless admin_signed_in?
  end
end
