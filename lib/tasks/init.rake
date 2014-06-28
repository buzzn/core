namespace :db do
  desc 'This rebuilds development db'
  task :init => [
                  'log:clear',
                  'tmp:cache:clear',
                  'assets:clean',
                  'carrierwave:delete_uploads',
                  'db:mongoid:drop',
                  'db:mongoid:remove_indexes',
                  'db:mongoid:create_indexes',
                  'db:drop',
                  'db:create',
                  'db:migrate',
                  'db:seed'
                ]
end