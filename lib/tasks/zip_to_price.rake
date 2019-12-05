# coding: utf-8
namespace :zip_to_price do

  desc 'Import zip to price data'
  task :import => :environment do
    file = File.join('db', 'csv', '2019-10-28_GetAG_ET.csv')
    ZipToPrice.from_csv(file, true)
    file = File.join('db', 'csv', '2019-10-28_GetAG_DT.csv')
    ZipToPrice.from_csv(file, false)
    ZipToPrice.clean_dsos
  end

  desc 'set zip price config'
  task :set_config => :environment do
    require './lib/buzzn/types/zip_price_config'
    CoreConfig.store Types::ZipPriceConfig.new(
      kwkg_aufschlag: 0.226,
      ab_la_v: 0.007,
      strom_nev: 0.305,  # §19 StromNEV-Umlage
      stromsteuer: 2.050,
      eeg_umlage:  6.756,
      offshore_haftung: 0.416, # Offshore Netzumlage
      deckungs_beitrag: 2.50, # Buzzn Bonus + Marge
      energie_preis: 5.00,  #  Stromgestehungskosten (SGK)
      vat: 1.19, # tax
      yearly_euro_intern: 41.64 # Grundpreise: Kosten von Schaebisch Hall + Marge
    )
  end

end
