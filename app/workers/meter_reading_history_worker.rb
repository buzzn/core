class MeterReadingHistoryWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(meter_id)
    meter = Meter.find(meter_id)

    meter.username
    meter.uid

    case meter.brand
    when 'discovergy'
      puts "It's between 1 and 5"
    when 'fluxo'
      puts "It's 6"
    else
      puts "You gave me #{@meter.brand} -- I have no idea what to do with that."
    end

  end

end