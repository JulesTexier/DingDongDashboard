class StaticPagesController < ApplicationController

    def dashboard

        # properties
        @properties_last_24h = Property.where('created_at > ?', 24.hours.ago)
        @properties_last_48h = Property.where('created_at > ?', 48.hours.ago)
        (@properties_last_48h.count - @properties_last_24h.count) != 0 ? @growth24h_props = (@properties_last_24h.count * 100 ) / (@properties_last_48h.count - @properties_last_24h.count) - 100 : "N/A"

        @properties_last_1m = Property.where('created_at > ?', 1.months.ago)
        @properties_last_2m = Property.where('created_at > ?', 2.months.ago)
        (@properties_last_2m.count - @properties_last_1m.count) != 0 ? @growth1m_props = (@properties_last_1m.count * 100 ) / (@properties_last_2m.count - @properties_last_1m.count) - 100 : "N/A"

        @properties_last_1w = Property.where('created_at > ?', 1.weeks.ago)
        @properties_last_2w = Property.where('created_at > ?', 2.weeks.ago)
        (@properties_last_2w.count - @properties_last_1w.count) != 0 ? @growth1w_props = (@properties_last_1w.count * 100 ) / (@properties_last_2w.count - @properties_last_1w.count) - 100 : "N/A"

        # subs
        @subs_last_24h = Subscriber.where('created_at > ?', 24.hours.ago)
        @subs_last_48h = Subscriber.where('created_at > ?', 48.hours.ago)
        (@subs_last_48h.count - @subs_last_24h.count) != 0 ? @growth24h_subs = (@subs_last_24h.count * 100 ) / (@subs_last_48h.count - @subs_last_24h.count) - 100 : "N/A"

        @subs_last_1m = Subscriber.where('created_at > ?', 1.months.ago)
        @subs_last_2m = Subscriber.where('created_at > ?', 2.months.ago)
        (@subs_last_2m.count - @subs_last_1m.count) != 0 ? @growth1m_subs = (@subs_last_1m.count * 100 ) / (@subs_last_2m.count - @subs_last_1m.count) - 100 : "N/A"

        @subs_last_1w = Subscriber.where('created_at > ?', 1.weeks.ago)
        @subs_last_2w = Subscriber.where('created_at > ?', 2.weeks.ago)
        (@subs_last_2w.count - @subs_last_1w.count) != 0 ? @growth1w_subs = (@subs_last_1w.count * 100 ) / (@subs_last_2w.count - @subs_last_1w.count) - 100 : "N/A"
    end

    def properties 
        @total = Property.all.count
        # @total1m = Property.where('created_at > ?', 30.days.ago).count
        # @total24h = Property.where('created_at > ?', 24.hours.ago).count

        # sites = Property.distinct.pluck(:source)
        @data = []
        sites.each do |source|
            @data.push({source: source, count: Property.where(source: source).count})
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
end
