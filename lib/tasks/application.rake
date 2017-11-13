namespace :application do

  desc 'Initialize a new or completely reset an existing application'
  task :init => %w(
    application:init:clear
    application:init:sidekiq
    application:init:carrierwave
    application:init:mongoid
    application:init:db
    db:seed:setup_data
  )
  # Right now we don't have any live features that require this data, so these tasks aren't executed, yet.
  # slp:import_h0
  # sep:import_pv_bhkw
  # banks:import
  # zip2price:all

  namespace :init do
    task clear: %w(log:clear tmp:clear)
    task sidekiq: %w(sidekiq:kill sidekiq:delete_queues)
    task carrierwave: %w(carrierwave:delete_uploads)
    task mongoid: %w(db:mongoid:drop db:mongoid:remove_indexes db:mongoid:create_indexes)
    task db: %w(db:drop db:create db:structure:load)
  end
end
