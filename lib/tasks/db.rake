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

    desc "Create the buzzn operator account for Philipp Oswald"
    task pho_user: :environment do
      require_relative '../../db/support/create_buzzn_operator'
      create_buzzn_operator(
        first_name: 'Phillip',
        last_name:  'Oßwald',
        email:      'philipp@buzzn.net',
        password:   Import.global('config.pho_account_password')
      )
    end

    desc "Create a generic buzzn operator account"
    task buzzn_operator: :environment do
      require_relative '../../db/support/create_buzzn_operator'
      create_buzzn_operator(
        first_name: 'Otto',
        last_name:  'Operator',
        email:      'dev+ops@buzzn.net',
        password:   Import.global('config.default_account_password')
      )
    end
  end
end
