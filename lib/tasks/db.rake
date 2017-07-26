Rake::Task["db:migrate"].enhance do

  Sequel.extension :migration

  config = ActiveRecord::Base.connection_config.dup
  database = config[:database]
  user = config[:username] || ENV['USER']
  path = Rails.root.join('db', 'sequel')

  Sequel.postgres(database, :user=> user) do |db|
    Sequel::Migrator.run(db, path.join('buzzn').to_s, :table=>'schema_info_buzzn')
  end
  user_ph = "#{user}_password"
  begin
    Sequel.postgres(database, :user=> user_ph) do |db|
      Sequel::Migrator.run(db, path.join('buzzn_ph').to_s, :table=>'schema_info_password')
    end
  rescue => e
    if user != user_ph
      user_ph = user
      retry
    else
      raise e
    end
  end
end
