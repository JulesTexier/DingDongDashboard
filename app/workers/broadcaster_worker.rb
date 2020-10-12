class BroadcasterWorker
  include Sidekiq::Worker
  sidekiq_options queue: :broadcaster

  def perform(broadcaster_type)
    case broadcaster_type
    when "live_broadcast"
      Broadcaster.new.live_broadcast
    when "good_morning"
      Broadcaster.new.good_morning
    when "good_morning_mailer"
      Broadcaster.new.good_morning_mailer
    else
      puts "Error in BroadcasterWorker."
    end
  end
end