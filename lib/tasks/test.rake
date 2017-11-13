# We're not using the built-in test tasks, see the spec tasks instead.
tasks_to_clear = %w(test test:all test:all:db test:db)
tasks_to_clear.each { |task_name| task(task_name).clear }
