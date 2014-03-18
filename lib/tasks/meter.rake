require_relative '../../app/workers/meter_reading_update_worker'

namespace :meter do

  task :reading_update => :environment do
    Meter.all.each do |meter|
      last = Reading.where(meter_id: meter.id).last.timestamp
      now  = DateTime.now.utc
      (last.to_i .. now.to_i).step(1.minutes) do |time|
        start_time = time * 1000
        end_time   = Time.at(time).end_of_minute.to_i * 1000
        MeterReadingUpdateWorker.perform_async(meter.id, start_time, end_time)
      end
    end
  end


end