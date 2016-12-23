module Buzzn

  module DataSourceCaching

    def self.included(clazz)
      clazz.class_eval do

        alias :raw_single_aggregated :single_aggregated
        alias :raw_collection :collection
        alias :raw_initialize :initialize

        def initialize(redis = Redis.current, *args)
          raw_initialize(*args)
          @redis = redis
          @lock = RemoteLock.new(RemoteLock::Adapters::Redis.new(redis))
        end

        {single_aggregated: Buzzn::DataResult, collection: Buzzn::DataResultArray}.each do |method, clazz|
          define_method method do |resource, mode|
            key = _cache_key(method, resource, mode)
            _with_lock(key) do
              result = clazz.from_json(_cache_get(key))
              if result.nil? || result.expires_at < Time.current.to_f
                Rails.logger.error("[datasource.caching]#{Thread.current} #{key} ====> stale")
                result = send("raw_#{method}".to_sym, resource, mode)
                _cache_put(key, result.to_json)
              else
                Rails.logger.error("[datasource.caching]#{Thread.current} #{key} ====> hit")
              end
              result
            end
          end
        end

        def _with_lock(key)
          @lock.synchronize(key, expiry: 2.seconds) do
            yield
          end
        end

        def _cache_get(key)
          @redis.get(key)
        end

        def _cache_put(key, result)
          @redis.set(key, result)
        end

        def _cache_key(prefix, resource, mode)
          "#{prefix}/#{self.class.to_s.underscore}/#{resource.class.table_name}/#{resource.id}/#{mode}"
        end
      end
    end
  end
end
