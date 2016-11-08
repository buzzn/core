class UpdateMeteringPointChartCache
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(metering_point_id, timestamp, resolution)
    if MeteringPoint.exists?(id: metering_point_id)
      metering_points_hash = Aggregate.sort_metering_points([MeteringPoint.find(metering_point_id)])
      aggregate = Aggregate.new(metering_points_hash)
      aggregate.past(timestamp: timestamp, resolution: resolution, refresh_cache: true)
    end
  end
end
