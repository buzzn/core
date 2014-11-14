require_relative '../../app/workers/meter_reading_update_worker'

namespace :meter do
  task :update => :environment do

    Meter.where(init_reading: true, smart: true, online: true).each do |meter|
      meter.registers.each do |register|
        mpoc            = register.metering_point.metering_point_operator_contract
        last            = Reading.latest_by_register_id(register.id)[:timestamp]
        now             = Time.now.in_time_zone.utc
        range           = (last.to_i .. now.to_i)
        if range.count < 60*60
          Sidekiq::Client.push({
           'class' => MeterReadingUpdateWorker,
           'queue' => :default,
           'args' => [
                      meter.registers_modes_and_ids,
                      meter.manufacturer_product_serialnumber,
                      mpoc.organization.slug,
                      mpoc.username,
                      mpoc.password,
                      last.to_i * 1000,
                      now.to_i * 1000
                     ]
          })
          puts "register_id: #{register.id} | from: #{Time.at(last)}, to: #{Time.at(now)}, #{range.count} seconds"
        else
          register.meter.update_columns(online: false)
        end
      end
    end

  end
end