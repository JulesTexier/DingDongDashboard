class ScrapSmallSitesWorker
  include Sidekiq::Worker

  def perform(*args)
    puts " > Hello from worker"
  end
end
