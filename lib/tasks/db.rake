namespace :db do

  desc 'Deletes all data in the database (without dropping, recreating or migrating it)'
  task empty: :environment do
    Rails.application.eager_load! # required so all active record classes are loaded and can be iterated over
    ActiveRecord::Base.connection.disable_referential_integrity do
      ActiveRecord::Base.descendants.each do |model|
        begin
          model.delete_all unless model.abstract_class?
        rescue => e
          puts "Failed to delete all #{model} records: #{e.message}"
        end
      end
    end
  end

  desc 'This rebuilds development db without any data'
  task :prepare => [
                  'log:clear',
                  'tmp:clear',
                  'assets:clean',
                  'sidekiq:kill',
                  'sidekiq:delete_queues',
                  'carrierwave:delete_uploads',
                  'db:mongoid:drop',
                  'db:mongoid:remove_indexes',
                  'db:mongoid:create_indexes',
                  'db:drop',
                  'db:create',
                  'db:migrate'
                ]

  desc 'This rebuilds development db without slp/sep'
  task :data => [
                   'db:prepare',
                   'db:seed:setup_data'
                 ]

  desc 'This rebuilds development db'
  task :init => [
                  'db:data',
                  'slp:import_h0',
                  'sep:import_pv_bhkw',
                  'zip2price:all',
                  'banks:import'
                ]

  Rake::Task["seed"].clear
  task :seed do
    puts "The db:seed rake task has been removed. Please use one of these instead:"
    system "rake -T db:seed"
  end
  namespace :seed do
    desc 'Loads essential data into the application'
    task setup_data: :environment do
      require_relative '../../db/setup_data'
    end

    desc 'Loads an example localpool with users etc. into the application'
    task example_data: 'db:seed:setup_data' do
      require_relative '../../db/example_data'
    end
  end
end
