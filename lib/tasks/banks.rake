namespace :banks do

  desc 'Import latest banks data'
  task :import => :environment do
    file = Dir["db/banks/*"].sort.last
    puts "process data from #{file}"
    Bank.update_from(file)
  end

end
