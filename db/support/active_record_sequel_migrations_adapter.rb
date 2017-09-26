module ActiveRecordSequelMigrationsAdapter
  def config
    config = ActiveRecord::Base.connection_config.dup
    # NOTE the PG_USER is for codeship
    config[:user] = config[:username] || ENV['PG_USER'] || ENV['USER']
    config.slice(:host, :user, :password, :port, :database)
  end

  def run_sequel_migration(number)
    Sequel.extension :migration
    Sequel.postgres(config[:database], config.except(:database)) do |db|
      migrations_path = Rails.root.join('db', 'sequel')
      puts "Running sequel migration #{number} from #{migrations_path}"
      Sequel::Migrator.run(db, migrations_path, target: number)
    end
  end
end
