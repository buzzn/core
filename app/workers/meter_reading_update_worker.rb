class MeterReadingUpdateWorker
  include Sidekiq::Worker

  def perform(register_id, manufacturer_device_number, mpo_slug, mpo_login_username, mpo_login_password, start_time, end_time, init_reading=false)
    Sidekiq::Queue['low'].limit = 2

    if mpo_slug == 'discovergy' or mpo_slug == 'buzzn-metering'

      api_call = Discovergy.new(mpo_login_username, mpo_login_password)

      if start_time && end_time
        request = api_call.raw(manufacturer_device_number, start_time, end_time)
      else
        request = api_call.raw(manufacturer_device_number) # use current time
      end

      if request['status'] == "ok"
        if request['result'].any?
          time       = request['result'].first['time']
          energy     = request['result'].first['energy']
          Reading.create(
            register_id:  register_id,
            timestamp:    DateTime.strptime(time.to_s,'%Q'),
            watt_hour:    energy / 10000000.0 #energy is in 10^-10 kWh; convert to Wh
          )
          if init_reading
            register = Register.find(register_id)
            register.meter.update_columns(init_reading: true)
          end
        else
          logger.warn "MeterReadingUpdateWorker: No result form request. starttime: #{start_time}, endtime: #{end_time}"
          register = Register.find(register_id)
          register.meter.update_columns(online: false)
        end
      end

    elsif mpo_slug == 'fluxo'
      puts "It's fluxo"
    else
      puts "You gave me #{mpo_slug} -- I have no idea what to do with that."
    end

  end
end