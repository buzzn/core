$LOAD_PATH << File.expand_path('.')

require 'lib/beekeeper/init'

namespace :beekeeper do
  desc "Run the migrations and spit out the generated attributes"
  task import: :environment do
    Beekeeper::MsbZählwerkDaten.all.each do |record|
      ap({ record.register_nr => record.converted_attributes })
    end
  end

  task :generate_models do
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
