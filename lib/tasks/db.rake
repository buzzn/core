# coding: utf-8
namespace :db do

  desc 'Deletes all data in the database (without dropping, recreating or migrating it)'
  task empty: :environment do
    require 'db/support/database_emptier'
    DatabaseEmptier.call
  end

  task reset: [:drop, :create, :migrate]

  namespace :dump do

    desc 'Drops the intermediary database used for pulling from a remote (i.e. heroku)'
    task :drop do
      password = Import.global('config.postgres_password')
      host =     Import.global('config.postgres_host')
      user =     Import.global('config.postgres_user')
      db =       Import.global('config.database_dump_name')
      sh "PGPASSWORD=#{password} dropdb -h #{host} -U #{user} --if-exists #{db}"
    end

    desc 'creates the intermediary database used for pulling from a remote (i.e. heroku)'
    task :create do
      password = Import.global('config.postgres_password')
      host =     Import.global('config.postgres_host')
      user =     Import.global('config.postgres_user')
      db =       Import.global('config.database_dump_name')
      sh "PGPASSWORD=#{password} createdb -h #{host} -U #{user} #{db}"
    end

    task reset: [:drop, :create]

    desc 'transfers data from the dump to the current database'
    task :transfer do
      require_relative '../../db/support/transfer'
      transfer_webforms
    end

  end

  Rake::Task['seed'].clear
  task seed: 'seed:setup_data'

  namespace :seed do

    task :print_warning do
      unless ENV['RACK_ENV'] == 'test' || ENV['CI']
        puts 'The local database will be dropped by this task.'
        puts 'Press Ctrl-C to abort, Enter to continue.'
        $stdin.gets
      end
    end

    desc 'Loads essential data into the application'
    task :setup_data do
      require_relative '../../db/setup_data'
    end

    desc 'Loads an example localpool with users etc. into the application. It requires a seeded/set up database.'
    task example_data: %w(setup_data) do
      require_relative '../../db/example_data'
    end

    desc 'Create the buzzn operator account for Philipp Oswald'
    task pho_user: :environment do
      require_relative '../../db/support/create_buzzn_operator'
      create_buzzn_operator(
        first_name: 'Phillip',
        last_name:  'Oßwald',
        email:      'philipp@buzzn.net',
        password:   Import.global('config.pho_account_password')
      )
    end

    desc 'Create a generic buzzn operator account'
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
