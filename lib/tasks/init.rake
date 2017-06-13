namespace :db do
  desc 'This rebuilds development db without any data'
  task :prepare => [
                  'log:clear',
                  'tmp:clear',
                  'assets:clean',
                  'sidekiq:kill',
                  'sidekiq:delete_queues',
                  'carrierwave:delete_uploads',
                  'capybara:delete_screenshots',
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
                   'db:seed'              
                 ]

  desc 'This rebuilds development db'
  task :init => [
                  'db:data',
                  'slp:import_h0',
                  'sep:import_pv_bhkw',
                  'banks:import'
                ]
end
