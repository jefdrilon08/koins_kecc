Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
Rack::MiniProfiler.config.storage_options = { url: REDIS_URL }
