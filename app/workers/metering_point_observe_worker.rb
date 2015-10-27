class MeteringPointObserveWorker
  include Sidekiq::Worker

  def perform(metering_point_id)
    @metering_point  = MeteringPoint.find(metering_point_id)
    @current_power   = Crawler.new(@metering_point).live[:power]


    if @current_power < @metering_point.min_watt
      message = I18n.t('undershot_min_watt')
    elsif @current_power > @metering_point.max_watt
      message = I18n.t('exceeded_max_watt')
    else
      message = nil
    end

    if message
      @metering_point.users.each do |user|
        Sidekiq::Client.push({
         'class' => PushNotificationWorker,
         'queue' => :default,
         'args' => [
                    user.id,
                    'warning',
                    @metering_point.name,
                    message,
                    10*1000
                   ]
        })
      end
    end

  end
end
