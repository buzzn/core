class UpdateMeteringPointChartCache
  include Sidekiq::Worker

  def perform(metering_point_id, resolution)
    @cache_id = "/metering_points/#{metering_point_id}/chart?resolution=#{resolution}&containing_timestamp="
    @now = (Time.now.in_time_zone.utc).to_i * 1000
    @fresh_chart = MeteringPoint.find(metering_point_id).send(resolution.to_sym, @now)
    Rails.cache.write(@cache_id, @fresh_chart, expires_in: 10.minute)
  end
end