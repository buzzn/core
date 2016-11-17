class PushReadingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(register_id, energy_a_milliwatt_hour, energy_b_milliwatt_hour, power_milliwatt, timestamp)
    Pusher.trigger( "register_#{register_id}",
                    'new_reading',
                    :energy_a_milliwatt_hour => energy_a_milliwatt_hour,
                    :energy_b_milliwatt_hour => energy_b_milliwatt_hour,
                    :power_milliwatt => power_milliwatt,
                    :timestamp => timestamp,
                    :register_id => "#{register_id}")
  end
end
