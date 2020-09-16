class BroadcasterWorker
  include Sidekiq::Worker
  sidekiq_options queue: :broadcaster

  def perform(broadcaster_type)
    case broadcaster_type
    when "live_broadcast"
      Broadcaster.new.live_broadcast
    when "good_morning"
      Broadcaster.new.good_morning
    else
      puts "Error in BroadcasterWorker."
    end
  end
end