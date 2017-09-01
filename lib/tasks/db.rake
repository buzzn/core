Rake::Task["db:structure:load"].enhance do
  require 'buzzn/db'
  db = Buzzn::DB
  if db[:account_statuses].count == 0
    db[:account_statuses].import([:id, :name], [[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']])
  end
end

Rake::Task["db:migrate"].enhance do

  Sequel.extension :migration

  config = ActiveRecord::Base.connection_config.dup
  database = config[:database]
  # NOTE the PG_USER is for codeship
  user = config[:username] || ENV['PG_USER'] || ENV['USER']
  path = Rails.root.join('db', 'sequel')
  options = { :user=> user, :password => config[:password], :port => config[:port] }
  begin
    Sequel.postgres(database, options) do |db|
      full = path.join('buzzn').to_s
      puts '--- sequel migration'
      puts full
      puts
      Sequel::Migrator.run(db, full, :table=>'schema_info_buzzn')
    end
    # NOTE the PG_USER is for codeship
    options[:user] = ENV['PG_USER'] || "#{user}_password"
    Sequel.postgres(database, options) do |db|
      full = path.join('buzzn_ph').to_s
      puts '--- sequel migration'
      puts full
      puts
      Sequel::Migrator.run(db, full, :table=>'schema_info_password')
    end
  rescue => e
    puts "\n\n=========== create missing DB user:\n\tcreateuser -U postgres #{options[:user]}"
    raise e
  end
end
