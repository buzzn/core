class MeteringPointObserveWorker
  include Sidekiq::Worker

  def perform(metering_point_id)
    @metering_point  = MeteringPoint.find(metering_point_id)
    @current_power   = Crawler.new(@metering_point).live[:power]


    if @current_power < @metering_point.min_watt
      message = I18n.t('metering_point_undershot_min_watt', @metering_point.min_watt)
    elsif @current_power > @metering_point.max_watt
      message = I18n.t('metering_point_exceeded_max_watt', @metering_point.max_watt)
    else
      message = nil
    end

    if message
      @metering_point.users.each do |user|
        user.send_notification('warning', @metering_point.name, message, 0, Rails.application.routes.url_helpers.metering_point_path(@metering_point))
      end
    end

  end
end
