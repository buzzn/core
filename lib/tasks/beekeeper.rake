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

    # Example: db/beekeeper_sql/minipooldb_2017-11-17_TT.zip => minipooldb
    def get_schema_name(file)
      File.basename(file).split('_').first
    end

    # Imports beekeeper MySQL dump to a postgres DB named after the file prefix (minipooldb).
    # Also dumps and zips the postgres data to FILENAME.postgres.zip.
    desc 'convert mysql dump to postgres dump FILE= required (can be a zip or sql file)'
    task :mysql2postgres do
      file   = get_unzipped(ENV['FILE'])
      schema = get_schema_name(file)
      sh "bin/mysql_2_postgres.sh #{file} #{schema}"
    end
  end

  desc 'Run the beekeeper import from the Beekeeper to our native DB'
  task import: :environment do
    # load the beekeeper stuff lazy on demand
    require 'lib/beekeeper/init'
    Beekeeper::Import.run!
  end

  task generate_models: :environment do
    schema = ENV['RAILS_ENV']
    namespace = schema.capitalize.sub(/db/, '')

    require 'pg'

    # Output a table of current connections to the DB
    conn = ActiveRecord::Base.connection
    query = "SELECT * FROM information_schema.tables WHERE table_schema='#{schema}'"
    tables = conn.execute(query).collect { |row| row['table_name']}
    tables.each do |table|
      p table
      class_definition = <<~CODE
        class Beekeeper::#{namespace}::#{table.camelize} < Beekeeper::#{namespace}::BaseRecord
          self.table_name = '#{schema}.#{table}'
        end
      CODE
      path = Rails.root.join("lib/beekeeper/models/#{namespace.downcase}/#{table}.rb")
      File.open(path, 'w+') { |f| f.write(class_definition) }
    end
  end

  namespace :person_images do
    desc 'Attach images in lib/beekeeper/person_images to the person records, uploads them to S3 if configured.'
    task attach: :environment do
      puts
      puts 'Attaching person images ...'
      Person.all.each do |person|
        next unless person.email
        file_name = person.email.downcase
        local_file_path = Rails.root.join('lib/beekeeper/person_images', "#{file_name}.jpg")
        putc '.'
        if File.exist?(local_file_path)
          puts "\nAssigning image #{local_file_path} to #{person.name}"
          person.update!(image: File.open(local_file_path))
        end
      end
    end
  end
end
