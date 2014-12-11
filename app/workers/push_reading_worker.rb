class PushReadingWorker
  include Sidekiq::Worker

  def perform(register_id, metering_point_id, watt_hour)
    Pusher.trigger("reading_#{metering_point_id}", 'new_reading', {:watt_hour => "#{watt_hour}"})
  end
end