namespace :zip_to_price do

  desc 'Import zip to price data'
  task :import => :environment do
    file = File.join('db', 'csv', 'GET_AG_2017ET_DTdot.csv')
    ZipToPrice.from_csv(file)
  end

  desc 'set zip price config'
  task :set_config => :environment do
    require './lib/buzzn/types/zip_price_config'
    CoreConfig.store Types::ZipPriceConfig.new(
      kwkg_aufschlag: 0.445,
      ab_la_v: 0.006,
      strom_nev: 0.388,
      stromsteuer: 2.050,
      eeg_umlage:  6.88,
      offshore_haftung: -0.028,
      deckungs_beitrag: 1.00,
      energie_preis: 5.00,
      vat: 1.19,
      yearly_euro_intern: 41.64
    )
  end

end
