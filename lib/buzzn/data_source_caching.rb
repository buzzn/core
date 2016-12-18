module Buzzn

  module DataSourceCaching

    CACHE = {}

    def self.included(clazz)
      clazz.class_eval do

        alias :raw_single_aggregated :single_aggregated
        alias :raw_collection :collection

        {single_aggregated: Buzzn::DataResult, collection: Buzzn::DataResultArray}.each do |method, clazz|
          define_method method do |resource, mode|
            key = _cache_key(method, resource, mode)
            _with_lock(key) do
              result = clazz.from_json(_cache_get(key))
              if result.nil? || result.expires_at < Time.current.to_f
                result = send("raw_#{method}".to_sym, resource, mode)
                _cache_put(key, result.to_json)
              end
              result
            end
          end
        end

        def _with_lock(key)
          RedisMutex.with_lock(key) do
            yield
          end
        end

        def _cache_get(key)
          CACHE[key]
        end

        def _cache_put(key, result)
          CACHE[key] = result
        end

        def _cache_key(prefix, resource, mode)
          "#{prefix}/#{self.class.to_s.underscore}/#{resource.class.table_name}/#{resource.id}/#{mode}"
        end
      end
    end
  end
end
