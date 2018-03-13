# We're not using the built-in test tasks, see the spec tasks instead.
tasks_to_clear = %w(test test:all test:all:db test:db)
tasks_to_clear.each { |task_name| task(task_name).clear }

namespace :test do
  desc 'Prepare the test DB for running the tests'
  task :prepare do
    # reset DB and load schema, but don't load any seed data, the test setup will take care of that.
    `RACK_ENV=test rake db:reset`
  end
end
