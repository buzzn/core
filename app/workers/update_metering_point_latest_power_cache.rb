class UpdateMeteringPointLatestPowerCache
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(metering_point_id)
    @cache_id = "/metering_points/#{metering_point_id}/latest_power"
    @fresh_last_power = MeteringPoint.find(metering_point_id).last_power
    Rails.cache.write(@cache_id, @fresh_last_power, expires_in: 5.minute)
  end
end