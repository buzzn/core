# coding: utf-8
namespace :zip_to_price do

  desc 'Import zip to price data'
  task :import => :environment do
    file = File.join('db', 'csv', '2020_GetAG_ET.csv')
    ZipToPrice.from_csv(file, true)
    file = File.join('db', 'csv', '2019-10-28_GetAG_DT.csv')
    ZipToPrice.from_csv(file, false)
    ZipToPrice.clean_dsos
  end

  desc 'set zip price config'
  task :set_config => :environment do
    require './lib/buzzn/types/zip_price_config'
    CoreConfig.store Types::ZipPriceConfig.new(
      kwkg_aufschlag: 0.254,
      ab_la_v: 0.009,
      strom_nev: 0.432,
      stromsteuer: 2.050,
      eeg_umlage:  6.5,
      offshore_haftung: 0.395,              # Offshore-Umlage
      deckungs_beitrag: 1.5,                # Marge
      energie_preis: 5.50,                  # Stromgestehungskosten + Buzzn_Bonus
      vat: 1.19,                            # Umsatzsteuer
      yearly_euro_intern: (1 + 2.47) * 12   # (Grundpreis_Schwaebisch_Hall + Marge) * 12
    )
  end

end
