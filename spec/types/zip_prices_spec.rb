require 'buzzn/types/zip_prices'
require 'buzzn/types/zip_price_config'

describe Types::ZipPrices do

  before :all do
    file = File.join('db', 'csv', 'GetAG_2018_ET_minimal.csv')
    ZipToPrice.from_csv(file, true)
    file = File.join('db', 'csv', 'GetAG_2018_DT_minimal.csv')
    ZipToPrice.from_csv(file, false)

    CoreConfig.store Types::ZipPriceConfig.new(
        kwkg_aufschlag: 1.0,
        ab_la_v: 1.0,
        strom_nev: 1.0,
        stromsteuer: 1.0,
        eeg_umlage:  1.0,
        offshore_haftung: 1.0,
        deckungs_beitrag: 1.0,
        energie_preis: 1.0,
        vat: 12.0,
        yearly_euro_intern: 0.07
    )
  end

  it 'max price when there is more then one DSO' do
    prices = Types::ZipPrices.new(zip: 1338, type: 'single', annual_kwh: 1)
    expect(prices.max_price.price.dso).to eq 'Vampire GmbH'
    expect(ZipToPrice.by_zip(1338).count).to eq 2
  end

  it 'max price when there is exactly one DSO' do
    prices = Types::ZipPrices.new(zip: 1337, type: 'single', annual_kwh: 1)
    expect(prices.max_price.price.dso).to eq 'Vampire GmbH'
    expect(ZipToPrice.by_zip(1337).count).to eq 1
  end
end
