class GetReadingWorker
  include Sidekiq::Worker

  def perform(registers_modes_and_ids, manufacturer_device_number, mpo_slug, mpo_login_username, mpo_login_password, start_time, end_time)

    if mpo_slug == 'discovergy' or mpo_slug == 'buzzn-metering'
      discovergy  = Discovergy.new(mpo_login_username, mpo_login_password)
      request     = discovergy.raw(manufacturer_device_number, start_time, end_time)

      if request['status'] == "ok"
        if request['result'].any?
          request['result'].each do |item|
            timestamp = DateTime.strptime(item['time'].to_s,'%Q')

            if registers_modes_and_ids.size == 1
              register_mode_and_id  = registers_modes_and_ids.first
              register_mode         = register_mode_and_id.first
              register_id           = register_mode_and_id.last
              watt_hour             = item['energy']
              Reading.create( register_id:  register_id,
                              timestamp:    timestamp,
                              watt_hour:    watt_hour, #energy is in 10^-10 kWh;
                            )
            else
              registers_modes_and_ids.each do |register_mode_and_id|
                register_mode = register_mode_and_id.first
                register_id   = register_mode_and_id.last
                if register_mode == 'in'
                  watt_hour = item['energy']
                elsif register_mode == 'out'
                  watt_hour = item['energyOut']
                end
                Reading.create( register_id:  register_id,
                                timestamp:    timestamp,
                                watt_hour:    watt_hour, #energy is in 10^-10 kWh;
                              )
              end
            end


          end

        else
          logger.warn "GetReadingWorker: No result form request. starttime: #{start_time}, endtime: #{end_time}"
        end
      elsif request['status'] == "error"
        logger.error request
      end


    elsif mpo_slug == 'fluxo'
      puts "It's fluxo"
    else
      puts "You gave me #{mpo_slug} -- I have no idea what to do with that."
    end

  end
end