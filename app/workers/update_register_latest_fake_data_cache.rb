class UpdateRegisterLatestFakeDataCache
  include Sidekiq::Worker

  def perform(register_id)
    @cache_id = "/registers/#{register_id}/latest_fake_data"
    @fresh_last_power = Register::Base.find(register_id).latest_fake_data
    Rails.cache.write(@cache_id, @fresh_last_power, expires_in: 5.minute)
  end
end