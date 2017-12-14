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

    desc "Create the login account for Philipp Oswald"
    task pho_user: :environment do
      require_relative '../../db/support/create_buzzn_operator'
      create_buzzn_operator(
        first_name: 'Phillip',
        last_name:  '0ßwald',
        email:      'philipp@buzzn.net',
        password:   Import.global('config.pho_account_password')
      )
    end
  end
end
