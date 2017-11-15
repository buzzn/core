# We're not using the built-in test tasks, see the spec tasks instead.
tasks_to_clear = %w(test test:all test:all:db test:db)
tasks_to_clear.each { |task_name| task(task_name).clear }

namespace :test do
  task :prepare do
    # reset DB and load schema, but don't load any seed data, the test setup will take care of that.
    `RAILS_ENV=test rake db:drop db:create db:structure:load`
  end
end
