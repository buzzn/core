Rake::Task["assets:precompile"].clear
Rake::Task["assets:clean"].clear

namespace :assets do
  task :precompile do
    puts "Task disabled, our API-only app doesn't need it."
  end
  task :clean do
    puts "Task disabled, our API-only app doesn't need it."
  end
end
