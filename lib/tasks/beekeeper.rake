namespace :beekeeper do

  desc 'convert mysql dump to postgres dump FILE= required (can be a zip or sql file)'
  task :mysql2postgres do
    file = ENV['FILE']
    if file =~ /.zip$/
      `unzip -o #{file}`
      file = file.sub(/.zip/, '.sql')
    end
    sh "bin/mysql_2_postgres.sh #{file}"
  end

  desc 'import sql-dump from FILE - db-name is the prefix of the filename until the first _ or - (can be a zip or sql file)'
  task :import do
    file = ENV['SQL']
    if file =~ /.zip$/
      `unzip -o #{file}`
      file = file.sub(/.zip/, '.sql')
    end
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
