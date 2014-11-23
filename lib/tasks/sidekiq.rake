namespace :sidekiq do

  task start: :environment do
    system "bundle exec sidekiq -C config/sidekiq.yml"
  end

  task kill: :environment do
    system "ps -ef | grep sidekiq | grep -v grep | awk '{print $2}' | xargs kill -9"
  end

  task delete_queues: :environment do
    Sidekiq::Queue.new("high").clear
    Sidekiq::Queue.new("default").clear
    Sidekiq::Queue.new("low").clear
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::Stats.new.reset
    Sidekiq.redis {|c| c.del('stat:processed') }
    Sidekiq.redis {|c| c.del('stat:failed') }
  end

end