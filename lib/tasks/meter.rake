require_relative '../../app/workers/meter_reading_update_worker'

namespace :meter do
  task :update => :environment do

    Meter.where(init_reading: true, smart: true, online: true).each do |meter|
      meter.registers.each do |register|
        mpoc            = meter.metering_point.metering_point_operator_contract
        last            = Reading.latest_by_register_id(register.id)[:timestamp].beginning_of_minute
        now             = Time.now.in_time_zone.utc.beginning_of_minute
        range           = (last.to_i .. now.to_i)
        range.step(1.minutes) do |time|
          if range.size > 5
            queue = time == range.last ? :default : :low
          else
            queue = :default
          end
          start_time = time * 1000
          end_time   = Time.at(time).end_of_minute.to_i * 1000

          Sidekiq::Client.push({
           'class' => MeterReadingUpdateWorker,
           'queue' => queue,
           'args' => [ 
                      register.id,
                      meter.manufacturer_product_serialnumber,
                      mpoc.organization.slug,
                      mpoc.username,
                      mpoc.password,
                      start_time,
                      end_time
                     ]
          })

          puts "queue: #{queue} | register_id: #{register.id},  start_time: #{start_time},  end_time: #{end_time}"
        end
      end
    end

  end
end