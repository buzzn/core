class MeterReadingUpdateWorker
  include Sidekiq::Worker

  def perform(register_id, manufacturer_device_number, mpo_name, mpo_login_username, mpo_login_password, start_time, end_time)

    if mpo_name == 'discovergy' or mpo_name == 'buzzn-metering'
      discovergy = Discovergy.new(mpo_login_username, mpo_login_password, "EASYMETER_#{manufacturer_device_number}")
      request     = discovergy.call(start_time, end_time)

      if request['status'] == "ok"
        if request['result'].any?
          time       = request['result'].first['time']
          energy     = request['result'].first['energy']
          Reading.create(
            register_id:  register_id,
            timestamp:    DateTime.strptime(time.to_s,'%Q'),
            watt_hour:    energy / 10000000.0 #energy is in 10^-10 kWh; convert to Wh
          )
        else
          logger.warn "MeterReadingUpdateWorker: No result form request. starttime: #{start_time}, endtime: #{end_time}"
        end
      elsif request['status'] == "error"
        logger.warn request
        register = Register.find(register_id)
        register.metering_point
      else
        logger.error request
      end

    elsif mpo_name == 'fluxo'
      puts "It's fluxo"
    else
      puts "You gave me #{mpo_name} -- I have no idea what to do with that."
    end

  end

end