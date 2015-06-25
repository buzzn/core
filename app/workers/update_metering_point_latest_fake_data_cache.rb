class UpdateMeteringPointLatestFakeDataCache
  include Sidekiq::Worker

  def perform(metering_point_id)
    @cache_id = "/metering_points/#{metering_point_id}/latest_fake_data"
    @fresh_last_power = MeteringPoint.find(metering_point_id).latest_fake_data
    Rails.cache.write(@cache_id, @fresh_last_power, expires_in: 5.minute)
  end
end