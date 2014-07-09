require_relative '../../app/workers/meter_reading_update_worker'

namespace :smartmeter do

  task :register_update => :environment do
    ['discovergy'].each do |msp_name|
      mspc                = MeteringServiceProviderContract.where(organization: Organization.where(name: msp_name) ).first
      register            = mspc.metering_point.register
      msp_login_username  = mspc.username
      msp_login_password  = mspc.password
      meter               = register.meter
      last                = Reading.where(register_id: register.id).last.timestamp
      now                 = Time.now
      (last.to_i .. now.to_i).step(1.minutes) do |time|
        start_time = time * 1000
        end_time   = Time.at(time).end_of_minute.to_i * 1000
        MeterReadingUpdateWorker.perform_async(
                                                register.id,
                                                meter.manufacturer_device_number,
                                                msp_name,
                                                msp_login_username,
                                                msp_login_password,
                                                start_time,
                                                end_time
                                              )
      end
    end
  end


end