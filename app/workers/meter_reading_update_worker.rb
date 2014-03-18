class MeterReadingUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(meter_id, start_time, end_time)
    meter = Meter.find(meter_id)
    meter.username
    meter.uid

    case meter.brand
    when 'discovergy'
      discovergy = Discovergy.new('stefan@buzzn.net', '19200buzzn', 'EASYMETER_1024000034')
      result     = discovergy.call(start_time, end_time)

      Reading.create(
        meter_id:  meter.id,
        timestamp: DateTime.strptime(result['result'].first['time'].to_s,'%Q'),
        wh:        result['result'].first['energy']
      )

    when 'fluxo'
      puts "It's 6"
    else
      puts "You gave me #{@meter.brand} -- I have no idea what to do with that."
    end

  end

end