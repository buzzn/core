namespace :zip2price do

  BASEDIR = 'db/csv'

  def data(name)
    file = File.join(BASEDIR, name)
    puts "process data from #{file}"
    File.read(file)
  end

  desc 'Import plz_ka.csv'
  task :zip_ka => :environment do
    ZipKa.from_csv(data('plz_ka.csv'))
  end
  
  desc 'Import plz_vnb.csv'
  task :zip_vnb => :environment  do
    ZipVnb.from_csv(data('plz_vnb.csv'))
  end
  
  desc 'Import nne_vnb.csv'
  task :nne_vnb => :environment  do
    NneVnb.from_csv(data('nne_vnb.csv'))
  end

  desc 'Import all zip to price csv file'
  task :all => [:zip_ka, :zip_vnb, :nne_vnb]
end
