namespace :migrationscripts do
  desc "Update all metering_points and meters to connect with a new register class"
  task update_models: :environment do
    metering_points = MeteringPoint.all
    puts 'Going to update ' + metering_points.count.to_s + 'MeteringPoints'
    ActiveRecord::Base.transaction do
      metering_points.each do |metering_point|
        register = Register.create( obis: metering_point.mode == "out" ? "1-0:2.8.0" : "1-0.1.8.0",
                                    virtual: metering_point.virtual)
        if !metering_point.meter_id.nil?
          meter = Meter.find(metering_point.meter_id)
          if !meter.nil?
            register.meter = meter
          end
        end
        register.metering_point = metering_point
        register.save
        puts '.'
      end
    end
    puts 'Finished.'
  end
end