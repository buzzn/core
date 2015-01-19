class PushReadingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(register_id, watt)
    Pusher.trigger("register_#{register_id}", 'new_reading', :watt => watt, :register_id => "#{register_id}")
  end
end