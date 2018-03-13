namespace :heroku do

  def push_local_db_to_heroku(env)
    app_name = "buzzn-core-#{env}"
    sh "heroku pg:reset --app=#{app_name}"
    sh "heroku pg:push buzzn_development DATABASE_URL --app=#{app_name}" do |ok, status|
      puts 'Note: warnings/errors about extension ownership can be ignored.' unless ok
    end
  end

  namespace :update_db do

    task import: %i(beekeeper:import beekeeper:person_images:attach)

    desc 'Run the beekeeper import and push the result to staging'
    task staging: %i(db:seed:example_data db:seed:buzzn_operator import) do
      push_local_db_to_heroku(:staging)
    end

    desc 'Run the beekeeper import and push the result to production'
    task production: %i(db:seed:setup_data db:seed:pho_user import) do
      push_local_db_to_heroku(:production)
    end
  end

end
