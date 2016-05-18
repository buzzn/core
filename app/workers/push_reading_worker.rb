class PushReadingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(metering_point_id, energy_a_milliwatt_hour, energy_b_milliwatt_hour, power_milliwatt, timestamp)
    Pusher.trigger( "metering_point_#{metering_point_id}",
                    'new_reading',
                    :energy_a_milliwatt_hour => energy_a_milliwatt_hour,
                    :energy_b_milliwatt_hour => energy_b_milliwatt_hour,
                    :power_milliwatt => power_milliwatt,
                    :timestamp => timestamp,
                    :metering_point_id => "#{metering_point_id}")
  end
end
