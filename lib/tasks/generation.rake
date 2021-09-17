# coding: utf-8
namespace :generation do

  desc 'Import generation data'
  task :import => :environment do
    file = File.join('db', 'csv', 'generation.csv')
    Groups.import_from_csv(file)
  end
end
