class PushReadingWorker
  include Sidekiq::Worker

  def perform(register_id, watt_hour)
    Pusher.trigger("register_#{register_id}", 'new_reading', {:watt_hour => "Aktueller Zählerstand: #{watt_hour / 1000.0} kWh", :register_id => "#{register_id}"})
  end
end