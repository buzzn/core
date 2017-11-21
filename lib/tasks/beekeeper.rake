$LOAD_PATH << File.expand_path('.')

namespace :beekeeper do

  namespace :sql do

    def unzip(file)
      dir = File.dirname(file)
      sh "unzip -o #{file} -d #{dir}"
      file.sub(/.zip/, '.sql')
    end

    def get_unzipped(file)
      file.ends_with?('.zip') ? unzip(file) : file
    end

    # Imports beekeeper MySQL dump to a postgres DB named after the file prefix (minipooldb).
    # Also dumps and zips the postgres data to FILENAME.postgres.zip.
    desc 'convert mysql dump to postgres dump FILE= required (can be a zip or sql file)'
    file = get_unzipped(ENV['FILE'])
    task :mysql2postgres do
      # Example: db/beekeeper_sql/minipooldb_2017-11-17_TT.zip => minipooldb
      schema = File.basename(file).split('_').first
      sh "bin/mysql_2_postgres.sh #{file} #{schema}"
    end

    desc 'import sql-dump from FILE - db-name is the prefix of the filename until the first _ or - (can be a zip or sql file)'
    task :import do
    file = get_unzipped(ENV['FILE'])
      env = file.sub(/[_-].*\z/, '')
      config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)[env]
      schema = config['database']
      db = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(config)

      db.drop rescue nil
      db.create
      db.structure_load(file)
      db.send(:run_cmd, 'psql', [ '-d', schema, '-c', "ALTER DATABASE #{schema} SET search_path TO #{schema}, public;"], 'adjust')
    end

    desc 'dump complete DB for RAILS_ENV - can be any rails env including "buzzndb" or "minipool" - default development'
    task :dump do
      env = ENV['RAILS_ENV'] || 'development'

      config = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)[env]
      db = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(config)
      args = ['-f', "#{env}-#{Date.today}.sql", config['database']]
      db.send(:run_cmd, 'pg_dump',  args, 'dumping')
    end
  end

  desc "Run the beekeeper import from the Beekeeper to our native DB"
  task import: :environment do
    # load the beekeeper stuff lazy on demand
    require 'lib/beekeeper/init'
    Beekeeper::Import.run!
  end

  task :generate_models do
    # load the beekeeper stuff lazy on demand
    require 'lib/beekeeper/init'
    require 'pg'

    # Output a table of current connections to the DB
    conn = ActiveRecord::Base.connection
    query = "SELECT * FROM information_schema.tables WHERE table_schema='minipooldb'"
    tables = conn.execute(query).map { |row| row['table_name']}
    tables.each do |table|
      class_definition = <<~CODE
        class Beekeeper::#{table.camelize} < Beekeeper::BaseRecord
          self.table_name = 'minipooldb.#{table}'
        end
      CODE
      path = Rails.root.join("lib/beekeeper/models/#{table}.rb")
      File.open(path, 'w+') { |f| f.write(class_definition) }
    end
  end
end
