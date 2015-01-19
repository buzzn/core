class PushReadingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(register_id, watt_hour, timestamp)
    Pusher.trigger("register_#{register_id}", 'new_reading', :watt_hour => watt_hour, :timestamp => timestamp, :register_id => "#{register_id}")
  end
end