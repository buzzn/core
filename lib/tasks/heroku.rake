namespace :heroku do

  def push_local_db_to_heroku(env)
    sh "heroku pg:reset --remote=#{env}"
    sh "heroku pg:push buzzn_development DATABASE_URL --remote=#{env}" do |ok, status|
      puts "Note: warnings/errors about extension ownership can be ignored." unless ok
    end
  end

  namespace :update_db do

    task :print_warning do
      puts "The local and heroku databases will be dropped and recreated."
      puts "Please make sure your local database has no open connections (close all clients)."
      puts "Press Ctrl-C to abort, Enter to continue."
      $stdin.gets
    end

    task reset_db: %i(db:drop db:create db:structure:load)
    task seed_and_import: %i(db:seed:example_data beekeeper:import)

    desc "Run the beekeeper import and push the result to staging"
    task staging: %i(print_warning reset_db seed_and_import) do
      push_local_db_to_heroku(:staging)
    end

    desc "Run the beekeeper import and push the result to production"
    task production: %i(print_warning reset_db seed_and_import db:seed:pho_user) do
      push_local_db_to_heroku(:production)
    end
  end

end
