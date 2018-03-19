# We're not using the built-in test tasks, we just run rspec from the CLI.
tasks_to_clear = %w(test test:all test:all:db test:db)
tasks_to_clear.each { |task_name| task(task_name).clear }

task :test do
  abort 'rake test doesn\'t do anything; please run rspec instead.'
end
