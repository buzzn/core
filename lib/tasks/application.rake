namespace :application do
  desc 'Initialize a new or completely reset an existing application'
  task :init => %w(log:clear tmp:clear carrierwave:delete_uploads db:reset)
end
