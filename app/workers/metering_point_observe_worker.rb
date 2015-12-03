class MeteringPointObserveWorker
  include Sidekiq::Worker

  def perform(metering_point_id)
    @metering_point  = MeteringPoint.find(metering_point_id)
    @last_reading = Crawler.new(@metering_point).live
    @current_power   = @last_reading[:power] if @last_reading

    if @current_power.nil?
      if @metering_point.observe_offline && @metering_point.last_observed_timestamp
        if Time.now >= @metering_point.last_observed_timestamp + 1.hour && Time.now <= @metering_point.last_observed_timestamp + 1.hour + 3.minutes
          [@metering_point.users + @metering_point.managers].flatten.uniq.each do |user|
            Notifier.send_email_notification_meter_offline(user, @metering_point)
          end
        end
      end
    else
      @metering_point.last_observed_timestamp = @last_reading[:timestamp]
      @metering_point.save
      if @current_power < @metering_point.min_watt
        message = I18n.t('metering_point_undershot_min_watt', @metering_point.min_watt)
        mode = 'undershoots'
      elsif @current_power >= @metering_point.max_watt
        message = I18n.t('metering_point_exceeded_max_watt', @metering_point.max_watt)
        mode = 'exceeds'
      else
        message = nil
      end
    end

    if message
      @metering_point.users.each do |user|
        user.send_notification('info', message, @metering_point.name, 0, Rails.application.routes.url_helpers.metering_point_path(@metering_point))
        Notifier.send_email_metering_point_exceeds_or_undershoots(user, @metering_point, mode)
      end
    end

  end
end
