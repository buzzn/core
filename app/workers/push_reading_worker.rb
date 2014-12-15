class PushReadingWorker
  include Sidekiq::Worker

  def perform(register_id, watt_hour)
    Pusher.trigger("register_#{register_id}", 'new_reading', {:watt_hour => "#{watt_hour}", :register_id => "#{register_id}"})
  end
end