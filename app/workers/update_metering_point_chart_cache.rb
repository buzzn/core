class UpdateMeteringPointChartCache
  include Sidekiq::Worker

  def perform(timestamp, resolution)
    MeteringPoint.all.each do |metering_point|
      metering_points_hash = Aggregate.sort_metering_points([metering_point])
      aggregate = Aggregate.new(metering_points_hash)
      aggregate.past(timestamp: timestamp, resolution: resolution, refresh_cache: true)
    end
  end
end
