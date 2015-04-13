class PushReadingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(metering_point_id, watt_hour, power, timestamp)
    Pusher.trigger("metering_point_#{metering_point_id}", 'new_reading', :watt_hour => watt_hour, :power => power, :timestamp => timestamp, :metering_point_id => "#{metering_point_id}")
  end
end