require_relative '../../app/workers/meter_reading_update_worker'

namespace :smartmeter do

  task :register_update => :environment do

    Meter.where(smart: true).each do |meter|
      registers       = meter.registers
      register        = registers.first # TODO not compatible with in_out smartmeter
      metering_point  = meter.registers.collect(&:metering_point).first
      mspc            = metering_point.metering_service_provider_contract
      last            = Reading.latest_by_register_id(register.id)[:timestamp]
      now             = Time.now.in_time_zone.utc
      (last.to_i .. now.to_i).step(1.minutes) do |time|
        start_time = time * 1000
        end_time   = Time.at(time).end_of_minute.to_i * 1000
        MeterReadingUpdateWorker.perform_async(
                                                register.id,
                                                meter.manufacturer_product_serialnumber,
                                                mspc.organization.name.downcase,
                                                mspc.username,
                                                mspc.password,
                                                start_time,
                                                end_time
                                              )
      end
    end
  end


end