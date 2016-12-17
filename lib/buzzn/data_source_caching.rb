module Buzzn

  module DataSourceCaching

    CACHE = {}

    class Mutex

      class Lock < ::Mutex

        attr_accessor :count
        def initialize
          @count = 0
        end
      end

      MUTEX = ::Mutex.new
      LOCKS = {}

      def initialize(key)
        @key = key
      end

      def with_lock
        lock = MUTEX.synchronize do
          l = (LOCKS[@key] ||= Lock.new)
          l.count += 1
          l
        end
        lock.synchronize do
          yield
        end
      ensure
        MUTEX.synchronize do
          lock.count -= 1
          if lock.count < 1
            LOCKS.delete(@key)
          end
        end
      end
    end

    def self.included(clazz)
      clazz.class_eval do

        alias :raw_single_aggregated :single_aggregated
        alias :raw_collection :collection

        [:single_aggregated, :collection].each do |method|
          define_method method do |resource, mode|
            key = _cache_key(method, resource, mode)
            _with_lock(key) do
              result = _cache_get(key)
              if result.nil? || result.expires_at < Time.current.to_f
                result = send("raw_#{method}".to_sym, resource, mode)
                _cache_put(key, result)
              end
              result
            end
          end
        end

        def _with_lock(key)
          Mutex.new(key).with_lock do
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
