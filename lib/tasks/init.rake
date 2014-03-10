namespace :db do
  desc 'This rebuilds development and test db'
  task :init => [
                  'log:clear',
                  'db:mongoid:drop',
                  'db:mongoid:remove_indexes',
                  'db:mongoid:create_indexes',
                  'db:drop',
                  'db:create',
                  'db:migrate',
                  'db:seed'
                ]
end