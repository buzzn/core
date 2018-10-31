namespace :heroku do

  def push_local_db_to_heroku(env)
    app_name = "buzzn-core-#{env}"
    sh "heroku pg:reset --app=#{app_name}"
    sh "heroku pg:push buzzn_development DATABASE_URL --app=#{app_name}" do |ok, status|
      puts 'Note: warnings/errors about extension ownership can be ignored.' unless ok
    end
    sh "heroku ps:restart --app=#{app_name}"
  end

  def pull_heroku_to_local_dump(env, dump_url)
    app_name = "buzzn-core-#{env}"
    sh "PGSSLMODE=allow heroku pg:pull DATABASE_URL #{dump_url} --app=#{app_name}"
  end

  namespace :pull_db do

    task staging: %i(db:dump:reset) do
      pull_heroku_to_local_dump(:staging, Import.global('config.database_dump_url'))
    end

    task production: %i(db:dump:reset) do
      pull_heroku_to_local_dump(:production, Import.global('config.database_dump_url'))
    end

  end

  namespace :update_db do

    task import: %i(beekeeper:import beekeeper:person_images:attach)

    desc 'Run the beekeeper import and push the result to staging'
    task staging:    %i(is_staging
                        db:reset
                        heroku:pull_db:staging
                        db:seed:example_data
                        db:seed:buzzn_operator
                        db:dump:transfer
                        import) do
      push_local_db_to_heroku(:staging)
    end

    desc 'Run the beekeeper import and push the result to production'
    task production: %i(is_production
                        db:reset
                        heroku:pull_db:production
                        db:seed:setup_data
                        db:seed:pho_user
                        db:dump:transfer
                        import) do
      push_local_db_to_heroku(:production)
    end

    task :is_staging do
      Dotenv.overload('.env.staging')
      raise "\nwrong or missing aws bucket, see docs/beekeeper.md\n" unless ENV['AWS_BUCKET'].include?('staging')
    end

    task :is_production do
      Dotenv.overload('.env.production')
      raise "\nwrong or missing aws bucket, see docs/beekeeper.md\n" unless ENV['AWS_BUCKET'].include?('production')
    end
  end

end
