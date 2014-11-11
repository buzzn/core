require_relative '../../app/workers/meter_reading_update_worker'

namespace :meter do
  task :update => :environment do

    Meter.where(init_reading: true, smart: true, online: true).each do |meter|
      meter.registers.each do |register|
        mpoc            = meter.metering_point.metering_point_operator_contract
        last            = Reading.latest_by_register_id(register.id)[:timestamp]
        now             = Time.now.in_time_zone.utc.end_of_minute
        range           = (last.to_i .. now.to_i)

        puts "register_id: #{register.id} | #{range.count/60} minutes"
        if range.count >= 60
          range.step(1.minutes) do |time|
            if range.size > 5
              queue = Time.at(time).end_of_minute == Time.at(range.last).end_of_minute ? :default : :low
            else
              queue = :default
            end
            start_time = Time.at(time).beginning_of_minute
            end_time   = Time.at(time).end_of_minute

            Sidekiq::Client.push({
             'class' => MeterReadingUpdateWorker,
             'queue' => queue,
             'args' => [
                        register.id,
                        meter.manufacturer_product_serialnumber,
                        mpoc.organization.slug,
                        mpoc.username,
                        mpoc.password,
                        start_time.to_i * 1000,
                        end_time.to_i * 1000
                       ]
            })
            puts "minute: #{Time.at(time)},  start_time: #{Time.at(start_time)},  end_time: #{Time.at(end_time)}, queue: #{queue}"
          end
        end
      end
    end

  end
end