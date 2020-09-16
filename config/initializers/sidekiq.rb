Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], size: 1 }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, :max_retries => 0
  end
end
