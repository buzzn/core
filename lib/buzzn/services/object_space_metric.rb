require_relative '../services'

class Services::ObjectSpaceMetric

  extend Dry::DependencyInjection::Eager
  include Import['services.metrics']

  def initialize(**)
    super
    @stats = {}
    @semaphore = Concurrent::Semaphore.new(1)
    @total = Leafy::Core::Gauge.new
    @free = Leafy::Core::Gauge.new
    @object = Leafy::Core::Gauge.new
    @string = Leafy::Core::Gauge.new
    metrics.register('objectspace.total', @total)
    metrics.register('objectspace.free', @free)
    metrics.register('objectspace.object', @object)
    metrics.register('objectspace.string', @string)
  end

  def non_blocking_sample
    if permits = @semaphore.drain_permits
      #GC.start
      ObjectSpace.count_objects(@stats)

      @total.value = @stats[:TOTAL]
      @free.value = @stats[:FREE]
      @object.value = @stats[:T_OBJECT]
      @string.value = @stats[:T_STRING]
    end
  ensure
    @semaphore.release(permits)
  end

end
