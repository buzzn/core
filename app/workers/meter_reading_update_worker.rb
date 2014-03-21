class MeterReadingUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(meter_id, start_time, end_time)
    meter = Meter.find(meter_id)
    
    

    case meter.brand
    when 'discovergy'
      discovergy = Discovergy.new(meter.username, meter.password, "EASYMETER_#{meter.uid}")
      result     = discovergy.call(start_time, end_time)
      time       = result['result'].first['time']
      energy     = result['result'].first['energy']


      Reading.create(
        meter_id:  meter.id,
        timestamp: DateTime.strptime(time.to_s,'%Q'),
        wh:        energy
      )

    when 'fluxo'
      puts "It's fluxo"
    else
      puts "You gave me #{@meter.brand} -- I have no idea what to do with that."
    end

  end

end