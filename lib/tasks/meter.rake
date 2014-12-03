require_relative '../../app/workers/get_reading_worker'

namespace :meter do

  task :pull_readings => :environment do
    Meter.pull_readings
  end

  task :reactivate => :environment do
    Meter.reactivate
  end

end