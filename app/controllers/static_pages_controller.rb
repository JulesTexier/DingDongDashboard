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
end
