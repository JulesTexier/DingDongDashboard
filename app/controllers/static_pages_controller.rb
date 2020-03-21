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
    @subscriber = Subscriber.all
    respond_to do |format|
      format.html
    end
  end
end
