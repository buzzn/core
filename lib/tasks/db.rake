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
