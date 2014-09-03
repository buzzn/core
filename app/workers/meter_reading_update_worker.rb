class MeterReadingUpdateWorker
  include Sidekiq::Worker
  # sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(register_id, manufacturer_device_number, msp_name, msp_login_username, msp_login_password, start_time, end_time)

    case msp_name
    when 'discovergy'
      discovergy = Discovergy.new(msp_login_username, msp_login_password, "EASYMETER_#{manufacturer_device_number}")
      request     = discovergy.call(start_time, end_time)

      if request['status'] == "ok"
        if request['result'].any?
          time       = request['result'].first['time']
          energy     = request['result'].first['energy']
          Reading.create(
            register_id:  register_id,
            timestamp:    DateTime.strptime(time.to_s,'%Q'),
            watt_hour:    energy
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

    when 'fluxo'
      puts "It's fluxo"
    else
      puts "You gave me #{@meter.brand} -- I have no idea what to do with that."
    end

  end

end