namespace :application do

  desc 'Initialize a new or completely reset an existing application'
  task :init => %w(
    application:init:clear
    application:init:carrierwave
    application:init:db
    db:seed:setup_data
  )
  # Right now we don't have any live features that require this data, so these tasks aren't executed, yet.
  # banks:import
  # zip2price:all

  namespace :init do
    task clear: %w(log:clear tmp:clear)
    task carrierwave: %w(carrierwave:delete_uploads)
    task db: %w(db:drop db:create db:structure:load)
  end
end
