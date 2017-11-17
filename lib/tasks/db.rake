namespace :db do

  desc 'Deletes all data in the database (without dropping, recreating or migrating it)'
  task empty: :environment do
    require 'db/support/database_emptier'
    DatabaseEmptier.call
  end

  Rake::Task["seed"].clear
  task seed: 'seed:setup_data'

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
