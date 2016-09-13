class MeteringPointObserveWorker
  include Sidekiq::Worker

  def perform(metering_point_id)
    @metering_point  = MeteringPoint.find(metering_point_id)
    @last_reading = Crawler.new(@metering_point).live
    @current_power   = @last_reading[:power] if @last_reading

    if @current_power.nil?
      if @metering_point.observe_offline && @metering_point.last_observed_timestamp
        if Time.now >= @metering_point.last_observed_timestamp + 1.hour && Time.now <= @metering_point.last_observed_timestamp + 1.hour + 3.minutes
          @metering_point.create_activity(key: 'metering_point.offline', owner: @metering_point)
        end
      end
    else
      @metering_point.last_observed_timestamp = Time.at(@last_reading[:timestamp]/1000).in_time_zone
      @metering_point.save
      if @current_power < @metering_point.min_watt && @current_power >= 0
        message = I18n.t('metering_point_undershot_min_watt', metering_point_name: @metering_point_name, min_watt: @metering_point.min_watt)
        mode = 'undershoots'
      elsif @current_power >= @metering_point.max_watt
        message = I18n.t('metering_point_exceeded_max_watt', metering_point_name: @metering_point_name, max_watt: @metering_point.max_watt)
        mode = 'exceeds'
      else
        message = nil
      end
    end

    if @metering_point.observe && message
      @metering_point.create_activity(key: "metering_point.#{mode}", owner: @metering_point)
    end

  end
end
