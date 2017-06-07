module Buzzn
  class DataSource
    module Caching

      def self.included(clazz)
        clazz.class_eval do

          alias :raw_single_aggregated :single_aggregated
          alias :raw_collection :collection
          alias :raw_initialize :initialize

          def initialize(*args)
            raw_initialize(*args)
            @logger = Buzzn::Logger.new(self)
            # use redis from args if there is
            @redis = args.detect { |a| a.is_a? Redis } || Redis.current
            @lock = RemoteLock.new(RemoteLock::Adapters::Redis.new(@redis))
          end

          {single_aggregated: Buzzn::DataResult, collection: Buzzn::DataResultArray}.each do |method, clazz|
            define_method method do |resource, mode|
              key = _cache_key(method, resource, mode)
              _with_lock(key) do
                # ignore corrupted cache entries
                result = clazz.from_json(_cache_get(key)) rescue nil
                if result.nil? || result.expires_at < Time.current.to_f
                  @logger.debug{"#{key} ====> stale"}
                  result = send("raw_#{method}".to_sym, resource, mode)
                  _cache_put(key, result.to_json)
                else
                  @logger.debug{"#{key} ====> hit"}
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
            #TODO remove this when we are sure we have Buzzn::EntityResource
            name = resource.class.respond_to?(:name) ?resource.class.name : resource.class.table_name
            "#{prefix}/#{self.class.to_s.underscore}/#{name}/#{resource.id}/#{mode}"
          end
        end
      end
    end
  end
end
