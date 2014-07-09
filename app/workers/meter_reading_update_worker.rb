class MeterReadingUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(register_id, manufacturer_device_number, msp_name, msp_login_username, msp_login_password, start_time, end_time)

    case msp_name
    when 'discovergy'
      discovergy = Discovergy.new(msp_login_username, msp_login_password, "EASYMETER_#{manufacturer_device_number}")
      result     = discovergy.call(start_time, end_time)
      time       = result['result'].first['time']
      energy     = result['result'].first['energy']

      Reading.create(
        register_id:  register_id,
        timestamp:    DateTime.strptime(time.to_s,'%Q'),
        watt_hour:    energy
      )

    when 'fluxo'
      puts "It's fluxo"
    else
      puts "You gave me #{@meter.brand} -- I have no idea what to do with that."
    end

  end

end