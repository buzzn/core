class UpdateGroupChartCache
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution)
    @cache_id = "/groups/#{group_id}/chart?resolution=#{resolution}&containing_timestamp="
    @now = (Time.now.in_time_zone.utc).to_i * 1000
    @fresh_chart = Group.find(group_id).chart(resolution, @now ).to_json
    Rails.cache.write(@cache_id, @fresh_chart, expires_in: 10.minute)
  end
end