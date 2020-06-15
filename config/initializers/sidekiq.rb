Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], size: 4 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], size: 2 }
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RetryJobs, :max_retries => 0
  end
end
