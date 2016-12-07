class UpdateRegisterLatestPowerCache
  include Sidekiq::Worker

  def perform(register_id)
    @cache_id = "/registers/#{register_id}/latest_power"
    @fresh_last_power = Register::Base.find(register_id).last_power
    Rails.cache.write(@cache_id, @fresh_last_power, expires_in: 5.minute)
  end
end