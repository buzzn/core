class MeterUpdateWorker
  include Sidekiq::Worker

  def range_to_reading(start,ending)
    puts "#{Time.at(start)} - #{Time.at(ending)}"

    Sidekiq::Client.push({
     'class' => MeterReadingUpdateWorker,
     'queue' => :low,
     'args' => [
                @registers_modes_and_ids,
                @manufacturer_product_serialnumber,
                @mpo_slug,
                @mpo_login_username,
                @mpo_login_password,
                start.to_i * 1000,
                ending.to_i * 1000
               ]
    })
  end

  def perform(registers_modes_and_ids, manufacturer_product_serialnumber, mpo_slug, mpo_login_username, mpo_login_password, start_time, end_time)
    @registers_modes_and_ids = registers_modes_and_ids
    @manufacturer_product_serialnumber = manufacturer_product_serialnumber
    @mpo_slug = mpo_slug
    @mpo_login_username = mpo_login_username
    @mpo_login_password = mpo_login_password

    if mpo_slug == 'discovergy' or mpo_slug == 'buzzn-metering'
      puts "get history for register: #{registers_modes_and_ids}"

      past = Time.at(start_time)
      now  = Time.at(end_time)

      start = nil
      ending = past
      while ending < now
        if start
          range_to_reading(start,ending)
          if (ending.to_i .. now.to_i).size < 1.hour
            range_to_reading(ending, now)
          end
        end
        start = ending
        ending += 3600
      end


    elsif mpo_slug == 'fluxo'
      puts "It's fluxo"
    else
      puts "You gave me #{mpo_slug} -- I have no idea what to do with that."
    end

  end
end