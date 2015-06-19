class UpdateGroupChartCache
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution, containing_timestamp)

    @group = Group.find(group_id)

    @cache_id = "/groups/#{params[:group_id]}/chart?resolution=#{params[:resolution]}&containing_timestamp=#{params[:containing_timestamp]}"

    case params[:resolution]
    when 'year_to_months'
      @expires_in = 60.minute
    when 'month_to_days'
      @expires_in = 60.minute
    when 'day_to_hours'
      @expires_in = 15.minute
    when 'day_to_minutes'
      @expires_in = 5.minute
    when 'hour_to_minutes'
      @expires_in = 5.minute
    else
      @expires_in = 10.seconds
    end

    Rails.cache.fetch(@cache_id, :expires_in => @expires_in ) do
      @group.send(params[:resolution], params[:containing_timestamp])
    end

  end
end