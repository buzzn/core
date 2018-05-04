namespace :maintenance do

  desc 'Maintenance mode on'
  task :on => :environment do
    CoreConfig.store(Types::MaintenanceMode.new(maintenance_mode: :on))
    puts 'maintenance-mode: on'
  end

  desc 'Maintenance mode off'
  task :off => :environment do
    CoreConfig.store(Types::MaintenanceMode.new(maintenance_mode: :off))
    puts 'maintenance-mode: off'
  end
end
