namespace :db do
  desc 'This rebuilds development and test db'
  task :init => ['log:clear',
                 'db:drop',
                 'db:create',
                 'db:migrate',
                 'db:seed']
end